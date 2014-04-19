//
//  AgentHTTPClient.h
//  AgentHTTP
//
//  Created by Tim Burks on 4/13/14.
//  Copyright (c) 2014 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AgentHTTPResult;

@interface AgentHTTPClient : NSObject

+ (AgentHTTPResult *) performRequest:(NSMutableURLRequest *) request;

@end
