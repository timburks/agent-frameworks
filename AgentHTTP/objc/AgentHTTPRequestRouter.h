#import <Foundation/Foundation.h>

@class AgentHTTPRequest;
@class AgentHTTPResponse;
@class AgentHTTPRequestHandler;

@interface AgentHTTPRequestRouter : NSObject

- (AgentHTTPResponse *) responseForHTTPRequest:(AgentHTTPRequest *) request;

- (void) insertHandler:(AgentHTTPRequestHandler *) handler level:(NSUInteger) level;

@end
