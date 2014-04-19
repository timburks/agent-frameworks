/*!
 @file AgentCrypto.h
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

#import <Foundation/Foundation.h>

@interface NSData (AgentCrypto)
- (NSData *) agent_md5Data;
- (NSData *) agent_sha1Data;
- (NSData *) agent_sha224Data;
- (NSData *) agent_sha256Data;
- (NSData *) agent_sha384Data;
- (NSData *) agent_sha512Data;
- (NSData *) agent_hmacMd5DataWithKey:(NSData *) key;
- (NSData *) agent_hmacSha1DataWithKey:(NSData *) key;
- (NSData *) agent_hmacSha224DataWithKey:(NSData *) key;
- (NSData *) agent_hmacSha256DataWithKey:(NSData *) key;
- (NSData *) agent_hmacSha384DataWithKey:(NSData *) key;
- (NSData *) agent_hmacSha512DataWithKey:(NSData *) key;
- (NSData *) agent_aesEncryptedDataWithPassword:(NSString *) password salt:(NSString *) salt;
- (NSData *) agent_aesDecryptedDataWithPassword:(NSString *) password salt:(NSString *) salt;
@end

@interface NSString (AgentCrypto)
- (NSString *) agent_md5HashWithSalt:(NSString *) salt;
@end
