//
//  AgentHTTPResult.m
//  AgentHTTP
//
//  Created by Tim Burks on 4/13/14.
//  Copyright (c) 2014 Radtastical Inc. All rights reserved.
//

#import "AgentHTTPResult.h"

@implementation AgentHTTPResult
@synthesize data, response, error;

- (NSString *) UTF8String {
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (id) propertyList {
    return [NSPropertyListSerialization propertyListWithData:self.data
                                                     options:0
                                                      format:NULL
                                                       error:NULL];
}
@end
