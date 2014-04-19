//
//  AgentHTTPServer.m
//  AgentHTTP
//
//  Created by Tim Burks on 2/24/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//
#import <Nu/Nu.h>
#import "AgentHTTPServer.h"
#import "AgentHTTPService.h"

#import "AgentCocoaHTTPServer.h"
#import "AgentLibEVHTPServer.h"

@implementation AgentHTTPServer
@synthesize service = _service, port, localOnly, verbose;

+ (void) load
{
    NSBundle *framework = [NSBundle frameworkWithName:@"AgentHTTP"];
    NSMutableDictionary *mainContext = [[Nu sharedParser] context];
    [framework loadNuFile:@"macros" withContext:mainContext];
}

- (id)initWithService:(AgentHTTPService *) service
{
    if (self = [super init]) {
        self.service = service;
        self.port = 8080;
        self.localOnly = NO;
        self.verbose = NO;
        
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        for (int i = 0; i < [arguments count]; i++) {
            NSString *argument = [arguments objectAtIndex:i];
            if (([argument isEqualToString:@"-p"] || [argument isEqualToString:@"--port"]) &&
                (i+1 < [arguments count])) {
                self.port = [[arguments objectAtIndex:++i] intValue];
            }
            else if (([argument isEqualToString:@"-l"] || [argument isEqualToString:@"--local"])) {
                self.localOnly = YES;
            }
            else if (([argument isEqualToString:@"-v"] || [argument isEqualToString:@"--verbose"])) {
                self.verbose = YES;
            }
        }
    }
    return self;
}

- (id) init
{
    return [self initWithService:[AgentHTTPService sharedService]];
}

- (void) start
{
    
}

- (void) run
{
    
}

+ (void) run
{
    if ([self isEqual:[AgentHTTPServer class]]) {
#ifdef DARWIN
        [[[AgentCocoaHTTPServer alloc] init] run];
#else
        [[[AgentLibEVHTPServer alloc] init] run];
#endif
    } else {
        [[[self alloc] init] run];
    }
}

+ (void) runVerbosely
{
    AgentHTTPServer *server;
    if ([self isEqual:[AgentHTTPServer class]]) {
#ifdef DARWIN
        server = [[AgentCocoaHTTPServer alloc] init];
#else
        server = [[AgentLibEVHTPServer alloc] init];
#endif
    } else {
        server = [[self alloc] init];
    }
    [server setVerbose:YES];
    [server run];
}

- (void) addEventWithOperation:(NSOperation *) operation
{
	
}

@end
