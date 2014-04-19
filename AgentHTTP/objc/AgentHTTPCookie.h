#import <Foundation/Foundation.h>

@interface AgentHTTPCookie : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDate *expiration;

+ (instancetype) cookieWithName:(NSString *) name
                          value:(NSString *) value;

- (instancetype) initWithName:(NSString *) name
                        value:(NSString *) value
                   expiration:(NSDate *) expiration;

- (NSString *) description;

- (NSString *) stringValue;

@end
