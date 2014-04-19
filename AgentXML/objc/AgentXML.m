//
//  AgentXML.m
//
//  Created by Tim Burks on 9/18/11.
//  Copyright (c) 2011 Radtastical Inc. All rights reserved.
//

#import "AgentXML.h"
#include <libxml/xmlreader.h>

@interface AgentXMLTextNode : NSObject
@property (nonatomic, strong) NSString *text;
@end

@implementation AgentXMLTextNode
@synthesize text;

- (NSString *) stringValue {
    return text;
}

@end

@implementation AgentXMLNode
@synthesize name, children, attributes, namespaceURI, localName, prefix;

- (id) init {
    if ((self = [super init])) {
        self.children = [NSMutableArray array];
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}


// http://www.jclark.com/xml/xmlns.htm
- (NSString *) universalName
{
    return [NSString stringWithFormat:@"{%@}%@", self.namespaceURI, self.localName];
}

- (NSString *) stringContents {
    NSMutableString *result = [NSMutableString string];
    for (id child in children) {
        [result appendString:[child stringValue]];
    }
    return result;
}

- (NSString *) stringValue {
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"<"];
    [result appendString:name];
    for (id key in [self.attributes allKeys]) {
        [result appendFormat:@" %@=\"%@\"", key, [self.attributes objectForKey:key]];
    }
    [result appendString:@">"];
    [result appendString:[self stringContents]];
    [result appendString:@"</"];
    [result appendString:name];
    [result appendString:@">"];
    return result;
}

- (NSString *) description {
    return [self stringValue];
}

@end

@implementation AgentXMLReader
@synthesize rootNode, error = _error;

- (id) init {
    if ((self = [super init])) {
        xmlStack = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) processNode:(xmlTextReaderPtr) reader {
    
    //xmlChar *node_baseURI      =  xmlTextReaderBaseUri(reader);
    xmlChar *node_localName    = xmlTextReaderLocalName(reader);
    xmlChar *node_name         = xmlTextReaderName(reader);
    xmlChar *node_namespaceURI = xmlTextReaderNamespaceUri(reader);
    xmlChar *node_prefix       = xmlTextReaderPrefix(reader);
    //xmlChar *node_XMLLang      = xmlTextReaderXmlLang(reader);
    xmlChar *node_value        = xmlTextReaderValue(reader);
    
    
    if (node_name == NULL)
        node_name = xmlStrdup(BAD_CAST "--");
    
    //int node_depth = xmlTextReaderDepth(reader);
    int node_type = xmlTextReaderNodeType(reader);
    int node_isempty = xmlTextReaderIsEmptyElement(reader);
    int node_hasattributes = xmlTextReaderHasAttributes(reader);
    
    if (node_type == XML_READER_TYPE_SIGNIFICANT_WHITESPACE) {
        return;
    }
    if (node_type == XML_READER_TYPE_COMMENT) {
        return;
    }
    if (node_type == XML_READER_TYPE_END_ELEMENT) {
        // NSLog(@"closing node %s", node_name);
        AgentXMLNode *lastObject = [xmlStack lastObject];
        [xmlStack removeLastObject];
        AgentXMLNode *newLastObject = [xmlStack lastObject];
        [newLastObject.children addObject:lastObject];
        return;
    }
    if (node_type == XML_READER_TYPE_TEXT) {
        // NSLog(@"xml text %s:%s", node_name, node_value);
        AgentXMLTextNode *node = [[AgentXMLTextNode alloc] init];
        node.text = [NSString stringWithCString:(const char *)node_value encoding:NSUTF8StringEncoding];
        AgentXMLNode *lastObject = [xmlStack lastObject];
        [[lastObject children] addObject:node];
        return;
    }
    if (node_type == XML_READER_TYPE_ELEMENT) {
        // NSLog(@"opening node %s %s %s", node_localName, node_namespaceURI, node_prefix);    
        
        AgentXMLNode *node = [[AgentXMLNode alloc] init];
        node.name = [NSString stringWithCString:(const char *)node_name
                                       encoding:NSUTF8StringEncoding];
        if (node_prefix) {
            node.prefix = [NSString stringWithCString:(const char *)node_prefix
                                             encoding:NSUTF8StringEncoding];
        }
        if (node_localName) {
            node.localName = [NSString stringWithCString:(const char *)node_localName
                                                encoding:NSUTF8StringEncoding];
        }
        if (node_namespaceURI) {
            node.namespaceURI = [NSString stringWithCString:(const char *)node_namespaceURI
                                                encoding:NSUTF8StringEncoding];
        }
        
        [xmlStack addObject:node];
        if (!rootNode) {
            self.rootNode = node;
        }
        /*
         XML_READER_TYPE_NONE = 0,
         XML_READER_TYPE_ELEMENT = 1,
         XML_READER_TYPE_ATTRIBUTE = 2,
         XML_READER_TYPE_TEXT = 3,
         XML_READER_TYPE_CDATA = 4,
         XML_READER_TYPE_ENTITY_REFERENCE = 5,
         XML_READER_TYPE_ENTITY = 6,
         XML_READER_TYPE_PROCESSING_INSTRUCTION = 7,
         XML_READER_TYPE_COMMENT = 8,
         XML_READER_TYPE_DOCUMENT = 9,
         XML_READER_TYPE_DOCUMENT_TYPE = 10,
         XML_READER_TYPE_DOCUMENT_FRAGMENT = 11,
         XML_READER_TYPE_NOTATION = 12,
         XML_READER_TYPE_WHITESPACE = 13,
         XML_READER_TYPE_SIGNIFICANT_WHITESPACE = 14,
         XML_READER_TYPE_END_ELEMENT = 15,
         XML_READER_TYPE_END_ENTITY = 16,
         XML_READER_TYPE_XML_DECLARATION = 17
         */
        
        if (node_hasattributes) {
            int more = xmlTextReaderMoveToNextAttribute(reader);
            while (more) {
                int nodeType = xmlTextReaderNodeType(reader);
                const char *name = (const char *) xmlTextReaderName(reader);
                const char *value = (const char *) xmlTextReaderValue(reader);
                // NSLog(@"attribute: %s=%s", name, value);
                if (nodeType == XML_READER_TYPE_ATTRIBUTE) {
                    AgentXMLNode *topObject = [xmlStack lastObject];
                    [topObject.attributes setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
                }
                more = xmlTextReaderMoveToNextAttribute(reader);
            }
        }
        
        if (node_isempty) {
            id lastObject = [xmlStack lastObject];
            //NSLog(@"last object %@", lastObject);
            [xmlStack removeLastObject];
            AgentXMLNode *newLastObject = [xmlStack lastObject];
            [newLastObject.children addObject:lastObject];
        }
    }
    xmlFree(node_name);
    if (node_value) {
        xmlFree(node_value);
    }
}

static void radXMLTextReaderErrorFunc(void *arg,
                                      const char *msg,
                                      xmlParserSeverities severity,
                                      xmlTextReaderLocatorPtr locator) {
    AgentXMLReader *reader = (__bridge AgentXMLReader *) arg;
    [reader setError:[NSError errorWithDomain:@"AgentXML"
                                         code:1
                                     userInfo:@{@"message":[NSString stringWithFormat:@"%s", msg]}]];
    NSLog(@"ERROR! %s", msg);
}

- (AgentXMLNode *) readXMLFromString:(NSString *)string error:(NSError **)error {
    self.rootNode = nil;
    self.error = nil;
    if (!string)
        return nil;
    const char *buffer = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int size = (int) strlen(buffer);
    xmlTextReaderPtr reader = xmlReaderForMemory(buffer, size, "", NULL, XML_PARSE_NOBLANKS);
    // XML_PARSE_DTDVALID
    
    xmlTextReaderSetErrorHandler(reader,
                                 radXMLTextReaderErrorFunc,
                                 (__bridge void *) self);
    
    
    // to read directly from a file, use this:
    // xmlTextReaderPtr reader = xmlNewTextReaderFilename([filename UTF8String]);
    if (reader != NULL) {
        int ret = xmlTextReaderRead(reader);
        while (ret == 1) {
            if (self.error) {
                if (error) {
                    *error = self.error;
                }
                self.rootNode = nil;
                [xmlStack removeAllObjects];
                return nil;
            }
            [self processNode:reader];
            ret = xmlTextReaderRead(reader);
        }
        xmlFreeTextReader(reader);
        if (ret != 0) {
            // bail out
            self.rootNode = nil;
            [xmlStack removeAllObjects];
            if (self.error) {
                if (error) {
                    *error = self.error;
                }
                self.rootNode = nil;
                [xmlStack removeAllObjects];
                return nil;
            }
            return nil;
        }
    } else {
        NSLog(@"Unable to open HTML");
        if (error) {
            *error = [[NSError alloc] initWithDomain:@"AgentXML" code:1 userInfo:nil];
        }
    }
    // the stack should be empty now
    [xmlStack removeAllObjects];
    return self.rootNode;
}

@end

