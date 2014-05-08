(load "AgentJSON")
(load "AgentHTTP")
(load "AgentCrypto")
(load "~/.agent.nu")

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
          (then ;; post the app binary
                (set result (AgentHTTPClient performPost:(+ AGENT "/control/apps/" (app _id:))
                                                withData:(NSData dataWithContentsOfFile:"build/#{(APP name:)}.zip")
                                             credentials:CREDENTIALS))
                (set version ((result object) version:))
                (puts "app version: #{version}")
                ;; trigger the app deployment
                (set result (AgentHTTPClient performPost:(+ AGENT "/control/apps/" (app _id:) "/" version "/deploy")
                                                withData:nil
                                             credentials:CREDENTIALS))
                (puts "deployment result: #{(result string)}"))
          (else (puts "app not found"))))

(task "pub" => "deploy")

(task "list" is
      (set result (AgentHTTPClient performGet:(+ AGENT "/control/apps") withCredentials:CREDENTIALS))
      (global APPS ((result object) apps:))
      (APPS each:
            (do (APP)
                (puts (+ (APP _id:) " " (APP name:)))))
      (puts (APPS description))
      "OK")

(task "show" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set result (AgentHTTPClient performGet:(+ AGENT "/control/apps/" (app _id:))
                                        withCredentials:CREDENTIALS))
                (puts "apps: #{((result object) description)}"))
          (else (puts "App not found"))))

(task "stop" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set result (AgentHTTPClient performPost:(+ AGENT "/control/apps/" (app _id:) "/stop")
                                                withData:nil
                                             credentials:CREDENTIALS))
                (puts "apps: #{(result string)}"))
          (else (puts "App not found"))))

(task "delete" => "list" is
      (set app (APPS find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set result (AgentHTTPClient performDelete:(+ AGENT "/control/apps/" (app _id:))
                                           withCredentials:CREDENTIALS))
                (puts "apps: #{(result string)}"))
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
                (puts "apps: #{(result string)}")
                (set appid ((result object) appid:)))))

(task "restart" is
      (set result (AgentHTTPClient performPost:(+ AGENT "/control/nginx/restart")
                                      withData:nil
                                   credentials:CREDENTIALS))
      (puts "result: #{(result string)}"))

(task "nginx" is
      (set result (AgentHTTPClient performGet:(+ AGENT "/control/nginx")
                              withCredentials:CREDENTIALS))
      (puts "result: #{(result string)}"))

(task "user" is
      (set result (AgentHTTPClient performGet:(+ AGENT "/control/user")
                              withCredentials:CREDENTIALS))
      (puts "user: #{(result string)}"))

(task "store" => "zip" is
      ;; look for the app on the store
      (set result (AgentHTTPClient performGet:(+ AGENT "/q/api/apps") withCredentials:CREDENTIALS))
      (set store_apps ((result object) apps:))
      (store_apps each:(do (APP) (puts (+ (APP _id:) " " (APP name:)))))
      (puts "STORE APPS")
      (puts (store_apps description))      
      (set app (store_apps find:(do (app) (eq (app name:) (APP name:)))))
      (if app
          (then (set appid (app _id:)))
          (else (puts "create app")
                ;; if it doesn't exist, create it
                (set result (AgentHTTPClient performPost:(+ AGENT "/q/api/apps")
                                              withObject:APP
                                             credentials:CREDENTIALS))
                (puts "create result: #{(result string)}")
                (set appid ((result object) appid:))))
      
      (puts "posting version for app #{appid}")
      (set result (AgentHTTPClient performPost:(+ AGENT "/q/api/apps/" appid)
                                      withData:(NSData dataWithContentsOfFile:(+ "build/" (APP name:) ".zip"))
                                   credentials:CREDENTIALS))
      (set version ((result object) version:))
      (puts "uploaded version #{version}")      
      "ok")

(task "default" => "zip")

(task "clean" is
      (system "rm -rf build"))

(task "clobber" => "clean")
