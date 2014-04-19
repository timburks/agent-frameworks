#!/usr/local/bin/nush
(load "AgentHTTP")

(get "/" "Hi there")

(get "/exit" (RESPONSE setExit:1) "bye!")

(get "/ps"
     (RESPONSE setValue:"text/plain" forHTTPHeader:"Content-Type")
     (NSString stringWithShellCommand:"ps uax"))

(get "/get" "GET")
(post "/post" "POST")

(put "/put"
     (puts "PUTTING!")
     (puts "#{((REQUEST body) length)} bytes")
     "PUT")

(delete "/delete" "DELETE")

(AgentLibEVHTPServer run)

