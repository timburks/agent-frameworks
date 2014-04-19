//
//  AgentXML.h
//
//  Created by Tim Burks on 9/18/11.
//  Copyright (c) 2011 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgentXMLNode : NSObject 
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *namespaceURI;

@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSMutableDictionary *attributes;

- (NSString *) universalName;
@end

@interface AgentXMLReader : NSObject {
    NSMutableArray *xmlStack;
}
@property (nonatomic, strong) AgentXMLNode *rootNode;
@property (nonatomic, strong) NSError *error;
- (AgentXMLNode *) readXMLFromString:(NSString *) string error:(NSError **) error;
@end

