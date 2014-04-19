//
//  AgentHTTPHelpers.h
//  AgentHTTP
//
//  Created by Tim Burks on 2/24/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (AgentHTTPHelpers)
- (NSString *) agent_urlEncodedString;
- (NSString *) agent_urlDecodedString;
- (NSDictionary *) agent_urlQueryDictionary;
@end

@interface NSData (AgentHTTPHelpers)
- (NSDictionary *) agent_urlQueryDictionary;
@end

@interface NSDictionary (AgentHTTPHelpers)
- (NSString *) agent_urlQueryString;
- (NSData *) agent_urlQueryData;
@end

@interface NSData (AgentBinaryEncoding)
- (NSString *) agent_hexEncodedString;
+ (id) agent_dataWithHexEncodedString:(NSString *) string;
@end

@interface NSDate (AgentHTTPHelpers)
- (NSString *) agent_rfc822String;
- (NSString *) agent_rfc1123String;
- (NSString *) agent_rfc3339String;
@end
