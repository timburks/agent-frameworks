(load "AgentJSON")

(if (eq (uname) "Linux")
     (then
          (set NSASCIIStringEncoding 1)
          (class NSString 
               (+ (id) stringWithContentsOfFile:(id)path encoding:(int)encoding error:(id)error is
                    (self stringWithContentsOfFile:path)))))

(class TestExamples is NuTestCase
     
     (- testJsonOrg is
        (set dir "test/json.org")
        (set files ((NSFileManager defaultManager) enumeratorAtPath:dir))
        (while (set file (files nextObject))
               (unless ((file pathExtension) isEqualToString:"json")
                       (continue))
               (set jsonPath (dir stringByAppendingPathComponent:file))
               (set plistPath ((jsonPath stringByDeletingPathExtension) stringByAppendingPathExtension:"plist"))
               (set jsonRep (NSString stringWithContentsOfFile:jsonPath
                                 encoding:NSASCIIStringEncoding
                                 error:nil))
               (set json (jsonRep agent_JSONValue))
               (assert_true json)
               (assert_equal json (((json agent_JSONRepresentation) agent_JSONValue)))
               (set plist (NSString stringWithContentsOfFile:plistPath
                               encoding:NSASCIIStringEncoding
                               error:nil))
               (unless plist (continue))
               (set expected (plist propertyList))
               (assert_equal expected json)
               (assert_equal expected (((expected agent_JSONRepresentation) agent_JSONValue)))))
     
     (- testRFC4627 is
        (set dir "test/rfc4627")
        (set files ((NSFileManager defaultManager) enumeratorAtPath:dir))
        (while (set file (files nextObject))
               (unless ((file pathExtension) isEqualToString:"json")
                       (continue))
               (set jsonPath (dir stringByAppendingPathComponent:file))
               (set plistPath ((jsonPath stringByDeletingPathExtension) stringByAppendingPathExtension:"plist"))
               (set jsonRep (NSString stringWithContentsOfFile:jsonPath
                                 encoding:NSASCIIStringEncoding
                                 error:nil))
               (set json (jsonRep agent_JSONValue))
               (assert_true json)
               (assert_equal json ((json agent_JSONRepresentation) agent_JSONValue))
               (set plist (NSString stringWithContentsOfFile:plistPath
                               encoding:NSASCIIStringEncoding
                               error:nil))
               (set expected (plist propertyList))
               (assert_equal expected json)
(unless (eq expected ((expected agent_JSONRepresentation) agent_JSONValue))
(puts "EXPECTED")
(puts (expected description))
(puts "ACTUAL")
(puts (((expected agent_JSONRepresentation) agent_JSONValue) description)))
               (assert_equal expected (((expected agent_JSONRepresentation) agent_JSONValue)))))
     
     (- testJsonChecker is
        (set dir "test/jsonchecker")
        (set files ((NSFileManager defaultManager) enumeratorAtPath:dir))
        (set agentjson (AgentJSON new))
        (agentjson setMaxDepth:19)
        (while (set file (files nextObject))
               (unless ((file pathExtension) isEqualToString:"json")
                       (continue))
               (set json (NSString stringWithContentsOfFile:(dir stringByAppendingPathComponent:file)
                              encoding:NSASCIIStringEncoding
                              error:nil))
               (if (file hasPrefix:"pass")
                   (then (assert_true (agentjson objectWithString:json error:nil)))
                   (else (assert_false (agentjson objectWithString:json error:nil)))))))
