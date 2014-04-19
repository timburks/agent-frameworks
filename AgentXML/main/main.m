//
//  main.m
//  RadXMLReader
//
//  Created by Tim Burks on 1/16/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgentXML.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {   
        chdir("/Users/tim/Desktop");
        NSString *string = [NSString stringWithContentsOfFile:@"propfind.xml" 
                                                     encoding:NSUTF8StringEncoding error:nil];
        string = @"<foo>";
        string = @"<D:propfind xmlns:D=\"DAV:\"><D:prop><bar:foo xmlns:bar=\"\"/></D:prop></D:propfind>";
        
        string = [NSString stringWithContentsOfFile:@"/Users/tim/propset.xml"
                                           encoding:NSUTF8StringEncoding
                                              error:nil];
        
        AgentXMLReader *reader = [[AgentXMLReader alloc] init];
        NSError *error;
        AgentXMLNode *root = [reader readXMLFromString:string error:&error];
        NSLog(@"result: %@", root);
        
        NSLog(@"ROOT: %@", [root name]);
        
        /*
        NSDictionary *schema = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSDictionary dictionaryWithObjectsAndKeys:                                
                                 @"somenames", @"somename", 
                                 nil], 
                                @"arrayNames",
                                [NSArray arrayWithObjects:@"text", @"title", nil], 
                                @"terminalNames",
                                nil];
                        
        
        NSLog(@"%@", [stuff dictionaryRepresentationWithSchema:nil]);
         */
    }
    return 0;
}

