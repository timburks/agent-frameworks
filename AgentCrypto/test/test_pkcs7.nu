;; test_pkcs7.nu
;;
;;  Copyright (c) 2013 Tim Burks, Radtastical Inc.

(load "AgentCrypto")

(class TestPKCS7 is NuTestCase
 
 (- testSigning is
    (set messageToSign (dict alphabet:"abcdefghijklmnopqrstuvwxyz"
                             integers:(array 0 1 2 3 4 5 6 7 8 9)))
    (set dataToSign (messageToSign XMLPropertyListRepresentation))
    (set certificate ((AgentX509Certificate alloc) initWithText:(NSString stringWithContentsOfFile:"test/test.crt")))
    (set key ((AgentEVPPKey alloc) initWithRSAKey:((AgentRSAKey alloc) initWithPrivateKeyText:(NSString stringWithContentsOfFile:"test/test.key"))))
    (set pkcs7 (AgentPKCS7Message signedMessageWithCertificate:certificate
                                                  privateKey:key
                                                        data:dataToSign))
    
    
    ;; if no certificate is specified, we read it from the message
    (set signedData (pkcs7 verifyWithCertificate:nil))
    (set signedMessage (signedData propertyListValue))
    (assert_equal messageToSign signedMessage)
    
    ;; here we explicitly specify the (correct) certificate
    (set signedData (pkcs7 verifyWithCertificate:certificate))
    (set signedMessage (signedData propertyListValue))
    (assert_equal messageToSign signedMessage)
    
    ;; here we explicitly specify the wrong certificate - the signature check should fail!
    (set certificate ((AgentX509Certificate alloc) initWithText:(NSString stringWithContentsOfFile:"test/test2.crt")))
    (set signedData (pkcs7 verifyWithCertificate:certificate))
    (set signedMessage (signedData propertyListValue))
    (assert_false signedMessage))
 
 (- testSigningWithAttributes is
    (set messageToSign (dict alphabet:"abcdefghijklmnopqrstuvwxyz"
                             integers:(array 0 1 2 3 4 5 6 7 8 9)))
    (set dataToSign (messageToSign XMLPropertyListRepresentation))
    (set certificate ((AgentX509Certificate alloc) initWithText:(NSString stringWithContentsOfFile:"test/test.crt")))
    (set key ((AgentEVPPKey alloc) initWithRSAKey:((AgentRSAKey alloc) initWithPrivateKeyText:(NSString stringWithContentsOfFile:"test/test.key"))))
    
    (set attributes (dict transactionID:"transaction-000"
                            messageType:"3" ; CertRep
                              pkiStatus:"0" ; Success
                         recipientNonce:("12345678" dataUsingEncoding:NSUTF8StringEncoding)
                            senderNonce:("ABCDEF10" dataUsingEncoding:NSUTF8StringEncoding)))
    (set pkcs7 (AgentPKCS7Message signedMessageWithCertificate:certificate
                                                  privateKey:key
                                                        data:dataToSign
                                            signedAttributes:attributes))
    
    (set signedData (pkcs7 verifyWithCertificate:nil))
    (set signedMessage (signedData propertyListValue))
    (set signedAttributes (pkcs7 attributes))
    (assert_equal attributes signedAttributes)
    (assert_equal messageToSign signedMessage))
 
 (- testEncryption is
    (set messageToEncrypt (dict alphabet:"abcdefghijklmnopqrstuvwxyz"
                                integers:(array 0 1 2 3 4 5 6 7 8 9)))
    (set dataToEncrypt (messageToEncrypt XMLPropertyListRepresentation))
    (set certificate ((AgentX509Certificate alloc) initWithText:(NSString stringWithContentsOfFile:"test/test.crt")))
    (set key ((AgentEVPPKey alloc) initWithRSAKey:((AgentRSAKey alloc) initWithPrivateKeyText:(NSString stringWithContentsOfFile:"test/test.key"))))
    (set pkcs7 (AgentPKCS7Message encryptedMessageWithCertificates:(array certificate)
                                                            data:dataToEncrypt))
    (set decryptedData (pkcs7 decryptWithKey:key certificate:certificate))
    (set decryptedMessage (decryptedData propertyListValue))
    (assert_equal messageToEncrypt decryptedMessage)
    
    ;; decrypt with the wrong key - the decryption should fail!
    (set certificate ((AgentX509Certificate alloc) initWithText:(NSString stringWithContentsOfFile:"test/test2.crt")))
    (set key ((AgentEVPPKey alloc) initWithRSAKey:((AgentRSAKey alloc) initWithPrivateKeyText:(NSString stringWithContentsOfFile:"test/test2.key"))))
    (set decryptedData (pkcs7 decryptWithKey:key certificate:certificate))
    (set decryptedMessage (decryptedData propertyListValue))
    (assert_false decryptedData)))