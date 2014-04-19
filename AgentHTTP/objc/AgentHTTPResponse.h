//
//  AgentHTTPResponse.h
//  AgentHTTP
//
//  Created by Tim Burks on 2/24/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AgentHTTPResponse : NSObject
@property (nonatomic, strong) NSData *body;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, assign) BOOL exit;

- (void) setValue:(NSString *) value forHTTPHeader:(NSString *) header;
- (NSString *) redirectResponseToLocation:(NSString *) location;

@end
