//
//  AgentHTTPResult.h
//  AgentHTTP
//
//  Created by Tim Burks on 4/13/14.
//  Copyright (c) 2014 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgentHTTPResult : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;

- (NSString *) string;
- (id) object;

@end
