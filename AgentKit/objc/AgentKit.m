//
//  AgentKit.m
//  AgentKit
//
//  Created by Tim Burks on 4/11/14.
//  Copyright (c) 2014 Radtastical Inc. All rights reserved.
//
#import <Nu/Nu.h>
#import "AgentKit.h"

@implementation AgentKit

+ (void) load
{
    NSBundle *framework = [NSBundle frameworkWithName:@"AgentKit"];
    NSMutableDictionary *mainContext = [[Nu sharedParser] context];
    [framework loadNuFile:@"common" withContext:mainContext];
}

@end
