//
//  AgentHTTPServer.h
//  AgentHTTP
//
//  Created by Tim Burks on 2/24/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@class AgentHTTPService;

//
// AgentHTTPServer
// A common interface for Objective-C web servers
//
@interface AgentHTTPServer : NSObject 
@property (nonatomic, assign) unsigned port;
@property (nonatomic, assign) BOOL localOnly;
@property (nonatomic, assign) BOOL verbose;
@property (nonatomic, strong) AgentHTTPService *service;

- (id)initWithService:(AgentHTTPService *) service;
- (void) start;
- (void) run;
- (void) runVerbosely;
- (void) addEventWithOperation:(NSOperation *) operation;

@end

