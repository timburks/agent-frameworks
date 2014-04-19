(load "AgentCrypto")

(set profileData ((dict alphabet:"abcdefghijklmnopqrstuvwxyz") XMLPropertyListRepresentation))
(NSLog "profile data length #{(profileData length)}")
(NSLog (profileData description))
(set certificate ((AgentX509Certificate alloc) initWithText:(NSString stringWithContentsOfFile:"test/test.crt")))
(set key ((AgentEVPPKey alloc) initWithRSAKey:((AgentRSAKey alloc) initWithPrivateKeyText:(NSString stringWithContentsOfFile:"test/test.key"))))

(set pkcs7 (AgentPKCS7Message encryptedMessageWithCertificates:(array certificate)
                                                        data:profileData))

(NSLog "======= ENCRYPTED DATA ======= ")
(NSLog ((pkcs7 dataRepresentation) description))
(NSLog "======= ENCRYPTED DATA ======= ")

(set decryptedData (pkcs7 decryptWithKey:key certificate:certificate))

(NSLog "======= DECRYPTED DATA ======= ")
(puts (NSString stringWithData:decryptedData encoding:NSUTF8StringEncoding))
(NSLog "======= DECRYPTED DATA ======= ")
