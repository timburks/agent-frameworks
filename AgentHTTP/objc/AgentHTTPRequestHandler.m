#import "AgentHTTPRequestHandler.h"
#import "AgentHTTPRequest.h"
#import "AgentHTTPResponse.h"
#import "AgentHTTPService.h"

@interface AgentHTTPRequestHandler ()
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) id block;
@property (nonatomic, strong) NSArray *parts; // used to expand pattern for request routing
@end

@implementation AgentHTTPRequestHandler
@synthesize httpMethod, path, block, parts;

+ (AgentHTTPRequestHandler *) handlerWithHTTPMethod:(id)httpMethod path:(id)path block:(id)block
{
    AgentHTTPRequestHandler *handler = [[AgentHTTPRequestHandler alloc] init];
    handler.httpMethod = httpMethod;
    handler.path = path;
    handler.parts = [[NSString stringWithFormat:@"%@%@", httpMethod, path]
                     componentsSeparatedByString:@"/"];
    handler.block = block;
    return handler;
}

+ (AgentHTTPRequestHandler *) handlerWithPath:(NSString *) path directory:(NSString *) directory
{
    AgentHTTPRequestHandler *handler = [[AgentHTTPRequestHandler alloc] init];
    handler.httpMethod = @"GET";
    handler.path = path;
    handler.parts = [[NSString stringWithFormat:@"%@%@", @"GET", path]
                     componentsSeparatedByString:@"/"];
    handler.block = ^(AgentHTTPRequest *REQUEST) {
        NSString *path = [REQUEST.bindings objectForKey:@"*path"];
        NSData *data = [NSData dataWithContentsOfFile:
                        [directory stringByAppendingPathComponent:path]];
        if (data) {
            AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
            response.body = data;
            [response setValue:[[AgentHTTPService sharedService] mimeTypeForFilename:path]
                 forHTTPHeader:@"Content-Type"];
            [response setValue:@"max-age=3600"
                 forHTTPHeader:@"Cache-Control"];
            return response;
        } else {
            return (AgentHTTPResponse *) nil;
        }
    };
    return handler;
}

static Class NuBlock;
static Class NuCell;

+ (void) initialize {
    NuBlock = NSClassFromString(@"NuBlock");
    NuCell = NSClassFromString(@"NuCell");
}

// Handle a request. Used internally.
- (AgentHTTPResponse *) responseForHTTPRequest:(AgentHTTPRequest *) request;
{
    // NSLog(@"handling request %@", [[request URL] description]);
    @autoreleasepool {
        if (NuBlock && NuCell && [self.block isKindOfClass:NuBlock]) {
            id args = [[NuCell alloc] init];
            [args performSelector:@selector(setCar:) withObject:request];
            return [self.block performSelector:@selector(evalWithArguments:context:)
                                    withObject:args
                                    withObject:[NSMutableDictionary dictionary]];
        } else {
            return ((id(^)(id)) self.block)(request);
        }
    }
}

@end
