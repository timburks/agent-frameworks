/*!
 @file AgentSSL.h
 @copyright Copyright (c) 2013 Radtastical, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

// WARNING - EVERYTHING IN THIS FILE IS EXPERIMENTAL JUNK AND SUBJECT TO CHANGE

// since this requires OpenSSL, we omit it from iPhone builds
#if !TARGET_OS_IPHONE

@interface AgentSSL : NSObject

- (void) setCAListFileName:(NSString *)CAListFileName;
- (void) setCAListData:(NSData *) cert_data;
- (void) setCAListText:(NSString *) cert_string;

- (void) setCertificateFileName:(NSString *)certificateFileName;
- (void) setCertificateData:(NSData *) cert_data;
- (void) setCertificateText:(NSString *) cert_string;

- (void) setKeyFileName:(NSString *)keyFileName;
- (void) setKeyData:(NSData *) key_data;
- (void) setKeyText:(NSString *) key_string;

- (BOOL) sendPayload:(NSString *) payloadString toDeviceWithToken:(NSString *) deviceTokenString;
- (void) connectToHost:(NSString *) host port:(int) port;
- (void) closeConnection;

@end

@interface NSData (AgentSSL)
+ (NSData *) agent_dataWithBIO:(BIO *) bio;
@end

@interface AgentRSAKey : NSObject {
@public
    RSA *rsa;
}
- (id) initWithPrivateKeyData:(NSData *) key_data;
- (id) initWithPrivateKeyText:(NSString *) key_string;
- (int) checkKey;
@end

@interface AgentEVPPKey : NSObject {
@public
    EVP_PKEY *pkey;
}
- (id) initWithRSAKey:(AgentRSAKey *) rsaKey;
@end

@interface AgentX509Request : NSObject {
    X509_REQ *req;
}
@end

@interface AgentX509Certificate : NSObject {
@public
    X509 *cert;
}
- (id) initWithData:(NSData *) cert_data;
- (id) initWithText:(NSString *) cert_string;
- (id) initWithX509:(X509 *) x509;
- (NSString *) name;
- (NSData *) dataRepresentation;
- (NSString *) textRepresentation;
@end

@interface AgentPKCS7Message : NSObject {
@public
    PKCS7 *p7;
}

+ (void) initialize;
+ (AgentPKCS7Message *) signedMessageWithCertificate:(AgentX509Certificate *) certificate
                                        privateKey:(AgentEVPPKey *) key
                                              data:(NSData *) dataToSign
                                  signedAttributes:(NSDictionary *) signedAttributes;
+ (AgentPKCS7Message *) degenerateWrapperForCertificate:(AgentX509Certificate *) certificate;
+ (AgentPKCS7Message *) encryptedMessageWithCertificates:(NSArray *) certificates
                                                  data:(NSData *) dataToEncrypt;
- (id) initWithData:(NSData *) data;
- (id) initWithPKCS7:(PKCS7 *) pkcs7;
- (NSData *) dataRepresentation;
- (NSString *) textRepresentation;
- (NSData *) decryptWithKey:(AgentEVPPKey *) key
                certificate:(AgentX509Certificate *) certificate;
- (AgentX509Certificate *) signerCertificate;
- (NSDictionary *) attributes;
- (NSData *) verifyWithCertificate:(AgentX509Certificate *) certificate;
@end

@interface AgentCertificateAuthority : NSObject

- (AgentX509Certificate *) generateCertificateForRequest:(NSData *) requestData
                                     withCACertificate:(AgentX509Certificate *) caCertificate
                                            privateKey:(AgentEVPPKey *) caPrivateKey;
@end

#endif