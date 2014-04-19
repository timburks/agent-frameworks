//
//  AgentHTTPService.h
//  AgentHTTP
//
//  Created by Tim Burks on 5/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AgentHTTPRequest;
@class AgentHTTPResponse;

@interface AgentHTTPService : NSObject

+ (AgentHTTPService *) sharedService;

- (void) addHandlerWithHTTPMethod:(NSString *) httpMethod path:(NSString *) path block:(id) block;
- (void) addHandlerWithPath:(NSString *) path directory:(NSString *) directory;

- (AgentHTTPResponse *) responseForHTTPRequest:(AgentHTTPRequest *) request;

- (void) setMimeType:(NSString *) mimeType forExtension:(NSString *) extension;
- (NSString *) mimeTypeForFilename:(NSString *) filename;

@end
