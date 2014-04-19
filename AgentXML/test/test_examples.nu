(load "AgentXML")

(def flatten (node)
     (if (node isKindOfClass:AgentXMLTextNode)
         (then (+ "\"" (node text) "\""))
         (else
              (set result "")
              (result appendString:"(")
              (result appendString:(node name))
              ((node children) each:
               (do (child)
                   (result appendString:" ")
                   (result appendString:(flatten child))))
              (result appendString:")")
              result)))

(class TestExamples is NuTestCase
 
 (- testProductsXML is
    (set data (NSData dataWithContentsOfFile:"test/products.xml"))
    (set string (NSString stringWithData:data encoding:NSUTF8StringEncoding))
    (set reader ((AgentXMLReader alloc) init))
    (set root (reader readXMLFromString:string error:nil))
    (set flattened (flatten root))
    (set expected (NSString stringWithContentsOfFile:"test/products.txt" encoding:NSUTF8StringEncoding error:nil))
    (assert_equal flattened expected)))