//
//  AgentHTTPClient.m
//  AgentHTTP
//
//  Created by Tim Burks on 4/13/14.
//  Copyright (c) 2014 Radtastical Inc. All rights reserved.
//

#import "AgentHTTPClient.h"
#import "AgentHTTPResult.h"

@implementation AgentHTTPClient

+ (AgentHTTPResult *) performRequest:(NSMutableURLRequest *) request
{
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];    
    AgentHTTPResult *result = [[AgentHTTPResult alloc] init];
    result.data = data;
    result.response = response;
    result.error = error;
    return result;
}

@end
