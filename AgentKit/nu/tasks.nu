(load "AgentJSON")
(load "AgentHTTP")
(load "AgentCrypto")

(class AgentHTTPClient
	
 (+ certifyRequest:request withCredentials:credentials is
    (set authorization (+ "Basic "
                          ((credentials dataUsingEncoding:NSUTF8StringEncoding)
                           agent_base64EncodedString)))
    (request setValue:authorization forHTTPHeaderField:"Authorization"))
 
 (+ performGet:path withCredentials:credentials is
    (set request (NSMutableURLRequest requestWithURL:(NSURL URLWithString:path)))
    (self certifyRequest:request withCredentials:credentials)
    (AgentHTTPClient performRequest:request))
 
 (+ performPost:path withData:data credentials:credentials is
    (set request (NSMutableURLRequest requestWithURL:(NSURL URLWithString:path)))
    (request setHTTPMethod:"POST")
    (request setHTTPBody:data)
    (request setValue:"application/plist" forHTTPHeaderField:"Content-Type")
    (self certifyRequest:request withCredentials:credentials)
    (AgentHTTPClient performRequest:request))
 
 (+ performPost:path withObject:object credentials:credentials is
    (puts "posting #{(object description)}")
    (set request (NSMutableURLRequest requestWithURL:(NSURL URLWithString:path)))
    (request setHTTPMethod:"POST")
    (request setHTTPBody:(object XMLPropertyListRepresentation))
    (request setValue:"application/plist" forHTTPHeaderField:"Content-Type")
    (self certifyRequest:request withCredentials:credentials)
    (AgentHTTPClient performRequest:request)))

(task "zip" is
      (SH "mkdir -p build/#{(APP name:)}.app")
      (((NSFileManager defaultManager) contentsOfDirectoryAtPath:"." error:nil) each:
       (do (file)
           (unless (or (/^build$/ findInString:file)
                       (/^Nukefile$/ findInString:file)
                       (/^data/ findInString:file)
                       (/^info/ findInString:file)
                       (/^test/ findInString:file)
                       (/^unused/ findInString:file))
                   (SH "cp -r #{file} build/#{(APP name:)}.app"))))
      (SH "cd build; zip -r #{(APP name:)}.zip #{(APP name:)}.app"))

(task "deploy" => "zip" "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then
               ;; upload a new app version
               (set command (+ "curl -s "
                               AGENT "/control/apps/" (app _id:)
                               " -T build/#{(APP name:)}.zip"
                               " -X POST"
                               " -u " CREDENTIALS))
               (puts command)
               (set results (NSData dataWithShellCommand:command))
               (set version ((results propertyListValue) version:))
               
               (puts "app version: #{version}")
               (set command (+ "curl -s "
                               AGENT "/control/apps/" (app _id:) "/" version "/deploy"
                               " -X POST"
                               " -u " CREDENTIALS))
               (set result (NSString stringWithShellCommand:command))
               (puts "deployment result: #{result}"))
          (else (puts "app not found"))))

(task "pub" => "deploy")

(task "list" is
      (set command (+ "curl -s "
                      AGENT "/control/apps"
                      " -u " CREDENTIALS))
      (puts command)
      (set results (NSData dataWithShellCommand:command))
      (global APPS ((results propertyListValue) apps:))
      (APPS each:
            (do (APP)
                (puts (+ (APP _id:) " " (APP name:)))))
      (puts (APPS description))
      "OK")

(task "show" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set command (+ "curl -s "
                                AGENT "/control/apps/" (app _id:)
                                " -X GET"
                                " -u " CREDENTIALS))
                (puts command)
                (set results (NSString stringWithShellCommand:command))
                (puts "apps: #{(results description)}"))
          (else (puts "App not found"))))

(task "stop" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set command (+ "curl -s "
                                AGENT "/control/apps/" (app _id:) "/stop"
                                " -X POST"
                                " -u " CREDENTIALS))
                (puts command)
                (set results (NSString stringWithShellCommand:command))
                (puts "apps: #{(results description)}"))
          (else (puts "App not found"))))

(task "delete" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set command (+ "curl -s "
                                AGENT "/control/apps/" (app _id:)
                                " -X DELETE"
                                " -u " CREDENTIALS))
                (puts command)
                (set results (NSString stringWithShellCommand:command))
                (puts "apps: #{(results description)}"))
          (else (puts "App not found"))))

(task "create" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (puts "App already exists"))
          (else (puts "Creating app")
                ;; if it doesn't exist, create it
                (set result (AgentHTTPClient performPost:(+ AGENT "/control/apps")
                                              withObject:APP
                                             credentials:CREDENTIALS))
                (puts "apps: #{(result UTF8String)}")
                (set appid ((result propertyList) appid:)))))


(task "restart" is
      (set command (+ "curl -s "
                      " -X POST"
                      " " AGENT "/control/nginx/restart"
                      " -u " CREDENTIALS))
      (puts command)
      (set results (NSString stringWithShellCommand:command))
      (puts "apps: #{(results description)}"))

(task "nginx" is
      (set command (+ "curl -s "
                      " -X GET"
                      " " AGENT "/control/nginx"
                      " -u " CREDENTIALS))
      (puts command)
      (set results (NSString stringWithShellCommand:command))
      (puts "apps: #{(results description)}"))

(task "user" is
      (set command (+ "curl -s "
                      " -X GET"
                      " " AGENT "/control/user"
                      " -u " CREDENTIALS))
      (puts command)
      (set results (NSString stringWithShellCommand:command))
      (puts "apps: #{(results description)}"))

(task "store" => "zip" is
      ;; look for the app on the store
      (set path (+ AGENT "/q/api/apps"))
      (set result (AgentHTTPClient performGet:path withCredentials:CREDENTIALS))
      (set store_apps ((result propertyList) apps:))
      (store_apps each:
                  (do (APP)
                      (puts (+ (APP _id:) " " (APP name:)))))
      (puts (store_apps description))
      
      (set app (store_apps find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set appid (app _id:)))
          (else (puts "create app")
                ;; if it doesn't exist, create it
                (set result (AgentHTTPClient performPost:(+ AGENT "/q/api/apps")
                                              withObject:APP
                                             credentials:CREDENTIALS))
                (puts "apps: #{(result UTF8String)}")
                (set appid ((result propertyList) appid:))))
      
      (puts "posting version for app #{appid}")
      (set result (AgentHTTPClient performPost:(+ AGENT "/q/api/apps/" appid)
                                      withData:(NSData dataWithContentsOfFile:(+ "build/" (APP name:) ".zip"))
                                   credentials:CREDENTIALS))
      (set version ((result propertyList) version:))
      (puts "uploaded version #{version}")
      
      "ok")





(task "default" => "zip")

(task "clean" is
      (system "rm -rf build"))

(task "clobber" => "clean")
