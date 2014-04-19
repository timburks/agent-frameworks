#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

// this expects AgentHTTP to be installed as a separate framework
// typically in /Library/Frameworks

#import "AgentLibEVHTPServer.h"
#import "AgentLibEventHTTPServer.h"
#import "AgentCocoaHTTPServer.h"
#import "AgentHTTPService.h"
#import "AgentHTTPResponse.h"
#import "AgentHTTPRequest.h"
#import "AgentHTTPHelpers.h"

#define CACHEDIRECTORY @"cache"

static void create_cache_directory(NSString *cacheDirectory) {
    NSError *error;
    // ensure that the cache directory is present
    BOOL isDirectory;
    BOOL itemExists = [[NSFileManager defaultManager]
                       fileExistsAtPath:cacheDirectory isDirectory:&isDirectory];
    if (!(itemExists && isDirectory)) {
        if (itemExists) {
            [[NSFileManager defaultManager] removeItemAtPath:cacheDirectory
                                                       error:&error];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
}

int main (int argc, const char *argv[])
{
    @autoreleasepool {
        static NSString *cacheDirectory = CACHEDIRECTORY;
        create_cache_directory(cacheDirectory);
        
        AgentHTTPService *service = [[AgentHTTPService alloc] init];
        
        
        [service addHandlerWithHTTPMethod:@"PUT" path:@"/put" block:
         ^(AgentHTTPRequest *request) {
            
            NSLog(@"PUT %d bytes", (int) [request.body length]);
             //NSString *string = [[NSString alloc] initWithData:request.body encoding:NSUTF8StringEncoding];
             //NSLog(@"%@", string);
             //NSLog(@"------");
             
             
            AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
            response.body = nil;
            return response;
            
        }];
        
       [service addHandlerWithHTTPMethod:@"HEAD" path:@"/*path:" block:
         ^(AgentHTTPRequest *request) {
             AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
             response.body = nil;
             NSLog(@"hit HEAD");
             return response;
         }];
    
        
        [service addHandlerWithHTTPMethod:@"GET" path:@"/" block:
         ^(AgentHTTPRequest *request) {
             AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
             response.body = [@"AgentHTTP" dataUsingEncoding:NSUTF8StringEncoding];
             NSLog(@"hit");
             //usleep(100000);
             //sleep(3);
             return response;
         }];
        
        [service addHandlerWithHTTPMethod:@"GET" path:@"/exit" block:
         ^(AgentHTTPRequest *request) {
             AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
             response.body = [@"exiting" dataUsingEncoding:NSUTF8StringEncoding];
             response.exit = YES;
             return response;
         }];
        
        [service addHandlerWithHTTPMethod:@"POST" path:@"/item" block:
         ^(AgentHTTPRequest *request) {
             NSString *contentType = [request.headers objectForKey:@"Content-Type"];
             NSString *creatorName = [request.headers objectForKey:@"Creator-Name"];
             NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                                   request.body, @"Body",
                                   [NSDate date], @"Creation-Time",
                                   contentType, @"Content-Type",
                                   creatorName, @"Creator-Name",
                                   nil];
             NSError *error;
             NSData *data = [NSPropertyListSerialization dataWithPropertyList:item
                                                                       format:NSPropertyListXMLFormat_v1_0
                                                                      options:0
                                                                        error:&error];
             
             unsigned char result[CC_MD5_DIGEST_LENGTH];
             CC_MD5([request.body bytes], (CC_LONG) [request.body length], result);
             NSData *hashData = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
             NSString *hashString = [hashData agent_hexEncodedString];
             [data writeToFile:[cacheDirectory stringByAppendingPathComponent:hashString] atomically:NO];
             AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
             response.body = [hashString dataUsingEncoding:NSUTF8StringEncoding];
             return response;
         }];
        
        [service addHandlerWithHTTPMethod:@"GET" path:@"/item/identifier:" block:
         ^(AgentHTTPRequest *request) {
             NSString *identifier = [request.bindings objectForKey:@"identifier"];
             NSData *data = [NSData dataWithContentsOfFile:
                             [cacheDirectory stringByAppendingPathComponent:identifier]];
             if (data) {
                 NSDictionary *info =
                 [NSPropertyListSerialization propertyListFromData:data
                                                  mutabilityOption:NSPropertyListImmutable
                                                            format:nil
                                                  errorDescription:nil];
                 AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
                 [response setValue:[info objectForKey:@"Content-Type"] forHTTPHeader:@"Content-Type"];
                 [response setValue:[info objectForKey:@"Creator-Name"] forHTTPHeader:@"Creator-Name"];
                 [response setValue:[info objectForKey:@"Creation-Time"] forHTTPHeader:@"Creation-Time"];
                 response.body = [info objectForKey:@"Body"];
                 return response;
             } else {
                 return (AgentHTTPResponse *) nil;
             }
         }];
        
        // File handler.
        [service addHandlerWithPath:@"/*path:" directory:@"public"];
        
        // "Not found" handler. This should always be last.
        [service addHandlerWithHTTPMethod:@"GET" path:@"/*path:" block:
         ^(AgentHTTPRequest *request) {
             NSString *path = [request.bindings objectForKey:@"*path"];
             AgentHTTPResponse *response = [[AgentHTTPResponse alloc] init];
             response.status = 404;
             response.body = [[NSString stringWithFormat:@"404 Not found: %@ %@", path, [request.URL description]]
                              dataUsingEncoding:NSUTF8StringEncoding];
             return response;
         }];
        
        //AgentCocoaHTTPServer *server = [[AgentCocoaHTTPServer alloc] initWithService:service];
        //AgentLibEventHTTPServer *server = [[AgentLibEventHTTPServer alloc] initWithService:service];
        AgentLibEVHTPServer *server = [[AgentLibEVHTPServer alloc] initWithService:service];
        [server setVerbose:YES];
        [server start];
    }
    return 0;
}
