
#import "AgentHTTPCookie.h"
#import "AgentHTTPHelpers.h"

@implementation AgentHTTPCookie
@synthesize name=_name, value=_value, expiration=_expiration;
 
+ (instancetype) cookieWithName:(NSString *) name value:(NSString *) value
{
    return [[self alloc] initWithName:name
                                value:value
                           expiration:[NSDate dateWithTimeIntervalSinceNow:3600]];
}

- (instancetype) initWithName:(NSString *) name
                        value:(NSString *) value
                   expiration:(NSDate *) expiration
{
    if (self = [super init]) {
        self.name = name;
        self.value = value;
        self.expiration = expiration;
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"cookie=#{%@} path=\"/\" value=#{%@} expiration=#{%@}", self.name, self.value, [self.expiration agent_rfc1123String]];
}

- (NSString *) stringValue
{
    return [NSString stringWithFormat:@"%@=%@; path=/; Expires:%@;",
            self.name,
            self.value,
            [self.expiration agent_rfc1123String]];
}

@end
