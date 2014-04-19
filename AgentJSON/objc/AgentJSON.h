
#import <Foundation/Foundation.h>

/// Adds JSON generation to NSObject subclasses
@interface NSObject (AgentJSON)

/**
 @brief Returns a string containing the receiver encoded as a JSON fragment.

 This method is added as a category on NSObject but is only actually
 supported for the following objects:
 @li NSDictionary
 @li NSArray
 @li NSString
 @li NSNumber (also used for booleans)
 @li NSNull
 */
- (NSString *) agent_JSONFragment;

/**
 @brief Returns a string containing the receiver encoded in JSON.

 This method is added as a category on NSObject but is only actually
 supported for the following objects:
 @li NSDictionary
 @li NSArray
 */
- (NSString *) agent_JSONRepresentation;

@end

/// Adds JSON parsing to NSString
@interface NSString (AgentJSON)

/// Returns the object represented in the receiver, or nil on error.
- (id) agent_JSONFragmentValue;

/// Returns the dictionary or array represented in the receiver, or nil on error.
- (id) agent_JSONValue;

@end


@interface NSData (AgentJSON)

/// Returns the dictionary or array represented in the receiver, or nil on error.
- (id) agent_JSONValue;

@end