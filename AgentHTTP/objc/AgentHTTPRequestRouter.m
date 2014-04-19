#import "AgentHTTPRequestHandler.h"
#import "AgentHTTPRequestRouter.h"
#import "AgentHTTPRequest.h"
#import "AgentHTTPResponse.h"

@interface AgentHTTPRequestHandler ()
@property (nonatomic, strong) NSArray *parts; // used to expand pattern for request routing
@end

@interface AgentHTTPRequestRouter ()
@property (nonatomic, strong) NSMutableDictionary *keyHandlers;
@property (nonatomic, strong) NSMutableArray *patternHandlers;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) AgentHTTPRequestHandler *handler;

// private methods
+ (AgentHTTPRequestRouter *) routerWithToken:(id) token;
- (void) insertHandler:(AgentHTTPRequestHandler *) handler level:(NSUInteger) level;
- (AgentHTTPResponse *) routeAndHandleRequest:(AgentHTTPRequest *) request parts:(NSArray *) parts level:(NSUInteger) level;

@end

static NSString *spaces(int n)
{
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < n; i++) {
        [result appendString:@" "];
    }
    return result;
}

@implementation AgentHTTPRequestRouter
@synthesize keyHandlers, patternHandlers, token, handler;

+ (AgentHTTPRequestRouter *) routerWithToken:(NSString *) token
{
    AgentHTTPRequestRouter *router = [[self alloc] init];
	router.token = [token copy];
    return router;
}

- (id) init {
    if ((self = [super init])) {
        self.keyHandlers = [[NSMutableDictionary alloc] init];
        self.patternHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *) descriptionWithLevel:(int) level
{
    NSMutableString *result;
    if (level >= 2) {
        result = [NSMutableString stringWithFormat:@"%@/%@%@\n",
                  spaces(level),
                  self.token,
                  self.handler ? @"  " : @" -"];
    }
    else {
        result = [NSMutableString stringWithFormat:@"%@%@\n",
                  spaces(level),
                  self.token];
    }
    id keys = [[self.keyHandlers allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (int i = 0; i < [keys count]; i++) {
        id key = [keys objectAtIndex:i];
        id value = [self.keyHandlers objectForKey:key];
        [result appendString:[value descriptionWithLevel:(level+1)]];
    }
    for (int i = 0; i < [self.patternHandlers count]; i++) {
        id value = [self.patternHandlers objectAtIndex:i];
        [result appendString:[value descriptionWithLevel:(level+1)]];
    }
    return result;
}

- (NSString *) description
{
    return [self descriptionWithLevel:0];
}

- (AgentHTTPResponse *) routeAndHandleRequest:(AgentHTTPRequest *) request parts:(NSArray *) parts level:(NSUInteger) level
{
    AgentHTTPResponse *response = nil;
    if (level == [parts count]) {
        @try
        {
            response = [self.handler responseForHTTPRequest:request];
        }
        @catch (id exception) {
            NSLog(@"Handler exception: %@ %@", [exception description], [request description]);
            if (YES) {  // DEBUGGING
                AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
                [response setValue:@"text/plain" forHTTPHeader:@"Content-Type"];
                response.body = [[exception description] dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
        return response;
    }
    else {
        id key = [parts objectAtIndex:level];
        id child;
        if ((child = [self.keyHandlers objectForKey:key])) {
            if ((response = [child routeAndHandleRequest:request parts:parts level:(level+1)])
                && ![response isEqual:[NSNull null]]) {
                return response;
            }
        }
        for (int i = 0; i < [self.patternHandlers count]; i++) {
            child = [self.patternHandlers objectAtIndex:i];
			NSString *childToken = [child token];
            if ([childToken characterAtIndex:0] == '*') {
                NSArray *remainingParts = [parts subarrayWithRange:NSMakeRange(level, [parts count] - level)];
                NSString *remainder = [remainingParts componentsJoinedByString:@"/"];
                [[request bindings] setObject:remainder
                                       forKey:[childToken substringToIndex:([childToken length]-1)]];
                if ((response = [child routeAndHandleRequest:request parts:parts level:[parts count]])
                    && ![response isEqual:[NSNull null]]) {
                    return response;
                }
            }
            else {
                [[request bindings] setObject:key
                                       forKey:[childToken substringToIndex:([childToken length]-1)]];
                if ((response = [child routeAndHandleRequest:request parts:parts level:(level + 1)])
                    && ![response isEqual:[NSNull null]]) {
                    return response;
                }
            }
            // otherwise, remove bindings and continue
            [[request bindings] removeObjectForKey:[childToken substringToIndex:([childToken length]-1)]];
        }
        return nil;
    }
}

- (void) insertHandler:(AgentHTTPRequestHandler *) h level:(NSUInteger) level
{
    if (level == [h.parts count]) {
        self.handler = h;
    }
    else {
        id key = [h.parts objectAtIndex:level];
        BOOL key_is_pattern = ([key length] > 0) && ([key characterAtIndex:([key length] - 1)] == ':');
        id child = key_is_pattern ? nil : [self.keyHandlers objectForKey:key];
        if (!child) {
            child = [AgentHTTPRequestRouter routerWithToken:key];
        }
        if (key_is_pattern) {
            [self.patternHandlers addObject:child];
        }
        else {
            [self.keyHandlers setObject:child forKey:key];
        }
        [child insertHandler:h level:level+1];
    }
}

- (AgentHTTPResponse *) responseForHTTPRequest:(AgentHTTPRequest *) request
{
    id httpMethod = request.method;
    NSArray *parts = [[NSString stringWithFormat:@"%@%@", httpMethod, [request path]]
                      componentsSeparatedByString:@"/"];
    if (([parts count] > 2) && [[parts lastObject] isEqualToString:@""]) {
        parts = [parts subarrayWithRange:NSMakeRange(0, [parts count]-1)];
    }
    AgentHTTPResponse *response = [self routeAndHandleRequest:request
                                                      parts:parts
                                                      level:0];
    
    if (!response && [httpMethod isEqualToString:@"HEAD"]) {
        httpMethod = @"GET";
        NSArray *parts = [[NSString stringWithFormat:@"%@%@", httpMethod, [request path]]
                          componentsSeparatedByString:@"/"];
        if (([parts count] > 2) && [[parts lastObject] isEqualToString:@""]) {
            parts = [parts subarrayWithRange:NSMakeRange(0, [parts count]-1)];
        }
        response = [self routeAndHandleRequest:request
                                         parts:parts
                                         level:0];
    }
    return response;
}



@end
