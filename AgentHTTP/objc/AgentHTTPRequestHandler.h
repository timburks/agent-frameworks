#import <Foundation/Foundation.h>

@class AgentHTTPRequest;
@class AgentHTTPResponse;

@interface AgentHTTPRequestHandler : NSObject 
+ (AgentHTTPRequestHandler *) handlerWithHTTPMethod:(id)httpMethod path:(id)path block:(id)block;
+ (AgentHTTPRequestHandler *) handlerWithPath:(NSString *) path directory:(NSString *) directory;
- (AgentHTTPResponse *) responseForHTTPRequest:(AgentHTTPRequest *) request;
@end