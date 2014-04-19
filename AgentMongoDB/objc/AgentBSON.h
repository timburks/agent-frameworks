/*!
@header AgentBSON.h
@discussion Declarations for the AgentBSON component.
@copyright Copyright (c) 2010 Radtastical, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import "Nu.h"
#else
#import <Nu/Nu.h>
#endif


/*!
   @class AgentBSON
   @abstract A BSON serializer and deserializer.
   @discussion BSON is the wire format used to communicate with MongoDB.
 */
@interface AgentBSON : NSObject

/*! Create a BSON representation from serialized NSData. */
+ (AgentBSON *) bsonWithData:(NSData *) data;
/*! Create an array of BSON objects from serialized NSData. */
+ (NSMutableArray *) bsonArrayWithData:(NSData *) data;

/*! Create a BSON representation of a dictionary object. */
+ (AgentBSON *) bsonWithDictionary:(NSDictionary *) dict;
/*! Create a BSON representation from a Nu list. */
+ (AgentBSON *) bsonWithList:(id) cell;

/*! Create a BSON representation from serialized NSData. */
- (AgentBSON *) initWithData:(NSData *) data;
/*! Create a BSON representation of a dictionary object. */
- (AgentBSON *) initWithDictionary:(NSDictionary *) dict;
/*! Create a BSON representation from a Nu list. */
- (AgentBSON *) initWithList:(id) cell;

/*! Return an NSData representation of the BSON object. */
- (NSData *) dataRepresentation;
/*! Return a dictionary equivalent of a BSON object. */
- (NSMutableDictionary *) dictionaryValue;

/*! Return an array containing all the top-level keys in the BSON object. */
- (NSArray *) allKeys;

/*! Return a named top-level element of the BSON object. */
- (id) objectForKey:(NSString *) key;
/*! Return a named element of the BSON object. */
- (id) objectForKeyPath:(NSString *) keypath;
@end

@interface AgentBSONObjectID : NSObject

/*! Create a new and unique object ID. */
+ (AgentBSONObjectID *) objectID;
/*! Create an object ID from a 12-byte data representation. */
+ (AgentBSONObjectID *) objectIDWithData:(NSData *) data;
/*! Create an object ID from a hex string. */
- (id) initWithString:(NSString *) s;
/*! Get the hex string value of an object ID. */
- (NSString *) stringValue;
/*! Create an object ID from an NSData representation. */
- (id) initWithData:(NSData *) data;
/*! Get the NSData representation of an object ID. */
- (NSData *) dataRepresentation;
/*! Compare two object ID values. */
- (NSComparisonResult)compare:(AgentBSONObjectID *) other;
/*! Test for equality with another object ID. */
- (BOOL)isEqual:(id)other;
@end


@interface AgentBSONComparator : NSObject
{
    AgentBSON *specification;
}
/*! Create a new and comparator for the given BSON specification. */
+ (AgentBSONComparator *) comparatorWithBSONSpecification:(AgentBSON *) s;
/*! Compare BSON data using the associated specification. */
- (int) compareDataAtAddress:(void *) aptr withSize:(int) asiz withDataAtAddress:(void *) bptr withSize:(int) bsiz;

@end


enum {
    AgentBSONReadingMutableContainers = (1UL << 0),
    AgentBSONReadingMutableLeaves = (1UL << 1),
    AgentBSONReadingAllowFragments = (1UL << 2)
};
typedef NSUInteger AgentBSONReadingOptions;
typedef NSUInteger AgentBSONWritingOptions;

@interface AgentBSONObjectSerialization : NSObject
+ (id)BSONObjectWithData:(NSData *)data options:(AgentBSONReadingOptions)opt error:(NSError **)error;
+ (NSData *)dataWithBSONObject:(id)obj options:(AgentBSONWritingOptions)opt error:(NSError **)error;
@end

// dubious convenience categories
@interface NSData (AgentBSON)
- (NSMutableDictionary *) agent_BSONValue;
@end

@interface NSDictionary (AgentBSON)
- (NSData *) agent_BSONRepresentation;
@end



