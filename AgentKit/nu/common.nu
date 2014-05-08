(load "AgentHTTP")

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
    (AgentHTTPClient performRequest:request))
 
 (+ performDelete:path withCredentials:credentials is
    (set request (NSMutableURLRequest requestWithURL:(NSURL URLWithString:path)))
    (request setHTTPMethod:"DELETE")
    (self certifyRequest:request withCredentials:credentials)
    (AgentHTTPClient performRequest:request)))

(set PASSWORD_SALT "agent.io")

(global &+ (NuMarkupOperator operatorWithTag:nil))

(macro redirect (location)
       `(progn (RESPONSE setStatus:303)
               (RESPONSE setValue:,location forHTTPHeader:"Location")
               "redirecting"))

(macro htmlpage (title *body)
       `(&html class:"no-js" lang:"en"
               (&head (&meta charset:"utf-8")
                      (&meta name:"viewport" content:"width=device-width, initial-scale=1.0")
                      (&meta name:"description" content:"My Agent on the Internet")
                      (&meta name:"author" content:"Agent I/O")
                      (&title ,title)
                      (&link rel:"icon" href:"/icon.png" type:"image/png")
                      (&link rel:"stylesheet" href:"/foundation-5/css/app.css")
                      (&script src:"/foundation-5/js/vendor/modernizr.js"))
               (&body ,@*body
                      (&script src:"/foundation-5/js/vendor/jquery.js")
                      (&script src:"/foundation-5/js/foundation.min.js")
                      (&script "$(document).foundation();"))))

(macro authenticate ()
       `(progn (set screen_name nil)
               (set session nil)
               (if (set cookie ((REQUEST cookies) session:))
                   (set mongo (AgentMongoDB new))
                   (mongo connect)
                   (set session (mongo findOne:(dict cookie:cookie) inCollection:"accounts.sessions"))
                   (set screen_name (session username:)))
               session))

(def js-delete (path)
     (+ "$.ajax({url:'" path "',type:'DELETE',success:function(response) {location.reload(true);}}); return false;"))

(def js-post (path arguments)
     (set command (+ "var form = document.createElement('form');"
                     "form.setAttribute('method', 'POST');"
                     "form.setAttribute('action', '" path "');"))
     (arguments each:
                (do (key value)
                    (command appendString:(+ "var field = document.createElement('input');"
                                             "field.setAttribute('name', '" key "');"
                                             "field.setAttribute('value', '" value "');"
                                             "form.appendChild(field);"))))
     (command appendString:"form.submit();")
     (command appendString:"return false;")
     command)

(set HOSTNAME (((NSString stringWithShellCommand:"hostname") componentsSeparatedByString:".") 0))

(macro topbar-for-app (appname additional-items)
       `(progn (set mongo (AgentMongoDB new))
               (mongo connect)
               (set system-apps (mongo findArray:(dict $query:(dict system:1 hidden:(dict $ne:1)) $orderby:(dict name:1)) inCollection:"control.apps"))
               (set available-apps (system-apps map:
                                                (do (app) (dict name:(app name:) path:(+ "/" (app path:))))))               
               (set current-app (available-apps find:(do (app) (eq (app name:) ,appname))))
               
               (unless (defined screen_name) (set screen_name nil))
               (unless (defined searchtext) (set searchtext ""))
               (set account_services (mongo findArray:(dict $query:(dict) $orderby:(dict vendor:1))
                                         inCollection:"accounts.services"))
               (&div class:"contain-to-grid" style:"margin-bottom:20px;"
                     (&nav class:"top-bar" data-topbar:1
                           (&ul class:"title-area"
                                (&li class:"divider")
                                (&li class:"name"
                                     (&h1 (&a href:"/home" HOSTNAME)))
                                (&li class:"divider")
                                (&li class:"toggle-topbar menu-icon" (&a href:"#" "Menu")))
                           (&section class:"top-bar-section"
                                     ;;<!-- Right Nav Section -->
                                     (if screen_name
                                         (&ul class:"right"
                                              (&li (&a href:"#" screen_name))
                                              (&li class:"active" (&a href:"#" "Sign out" onclick:(js-post "/accounts/signout" nil)))
                                              (&li class:"divider")
                                              ))
                                     
                                     ;;<!-- Left Nav Section -->
                                     (if screen_name
                                         (&ul class:"left"
                                              (available-apps map:
                                                              (do (app)
                                                                  (+ (&li class:"divider")
                                                                     (&li (&a href:(app path:) (app name:)))
                                                                     (if (eq (app name:) ,appname)
                                                                         (then (&+ ,additional-items))
                                                                         (else ""))))))))))))


(macro mongo-connect ()
       `(progn (unless (defined mongo)
                       (set mongo (AgentMongoDB new))
                       (mongo connect))))

(function html-escape (s)
          ((((s stringByReplacingOccurrencesOfString:"&" withString:"&amp;")
             stringByReplacingOccurrencesOfString:"<" withString:"&lt;")
            stringByReplacingOccurrencesOfString:">" withString:"&gt;")
           stringByReplacingOccurrencesOfString:"\"" withString:"&quot;"))

((set date-formatter
      ((NSDateFormatter alloc) init))
 setDateFormat:"EEEE MMMM d, yyyy")

((set rss-date-formatter
      ((NSDateFormatter alloc) init))
 setDateFormat:"EEE, d MMM yyyy hh:mm:ss ZZZ")

(function oid (string)
          ((AgentBSONObjectID alloc) initWithString:string))

(class NSArray
 (- subarraysOfN:n is
    (set a (array))
    (set current (array))
    (self each:
          (do (item)
              (if (eq (current count) 0)
                  (a << current))
              (current << item)
              (if (eq (current count) n)
                  (set current (array)))))
    a))


