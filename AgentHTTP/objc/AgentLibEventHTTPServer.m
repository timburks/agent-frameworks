//
//  AgentLibEventHTTPServer.m
//  AgentHTTP
//
//  Created by Tim Burks on 5/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "AgentLibEventHTTPServer.h"
#import "AgentHTTPRequest.h"
#import "AgentHTTPResponse.h"
#import "AgentHTTPService.h"

#include <sys/types.h>
#include <sys/time.h>
#include <sys/queue.h>

#include <event2/event.h>
#include <event2/http.h>
#include <event2/util.h>
#include <event2/event_struct.h>
#include <event2/event_compat.h>
#include <event2/http_compat.h>
#include <event2/http_struct.h>
#include <event2/buffer.h>
#include <event2/buffer_compat.h>

#include <netdb.h>
#include <arpa/inet.h>                            // inet_ntoa
#include <event2/dns.h>
#include <event2/dns_compat.h>
#include <event2/event.h>

#include <signal.h>                               // SIGPIPE

@interface AgentLibEventHTTPServer ()
{
    struct event_base *event_base;
    struct evhttp *httpd;
}
@property (nonatomic, strong) NSMutableArray *operationQueue;

- (void)processRequest:(AgentHTTPRequest *)request;

@end


static NSString *method_for_request(struct evhttp_request *req)
{
    switch (req->type) {
        case EVHTTP_REQ_GET:
            return @"GET";
        case EVHTTP_REQ_POST:
            return @"POST";
        case EVHTTP_REQ_HEAD:
            return @"HEAD";
        case EVHTTP_REQ_PUT:
            return @"PUT";
        case EVHTTP_REQ_DELETE:
            return @"DELETE";
        default:
            return @"UNKNOWN";
    }
}

static NSDictionary *rad_request_headers_helper(struct evhttp_request *req)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    struct evkeyval *header;
    TAILQ_FOREACH(header, req->input_headers, next) {
        [dict setObject:[NSString stringWithCString:header->value encoding:NSUTF8StringEncoding]
                 forKey:[NSString stringWithCString:header->key encoding:NSUTF8StringEncoding]];
    }
    return dict;
}

static NSData *rad_request_body_helper(struct evhttp_request *req)
{
	unsigned long length = evbuffer_get_length(req->input_buffer);
    if (!length)
        return nil;
    else {
		unsigned char *bytes = evbuffer_pullup(req->input_buffer, -1);
        return [NSData dataWithBytes:bytes length:length];
    }
}

static void rad_request_handler(struct evhttp_request *req, void *server_context)
{
    AgentLibEventHTTPServer *server = (__bridge AgentLibEventHTTPServer *) server_context;
    AgentHTTPRequest *request = [[AgentHTTPRequest alloc] init];

    const struct evhttp_uri *uri = evhttp_request_get_evhttp_uri (req);
    const char *schemeString = evhttp_uri_get_scheme(uri);
    NSString *scheme;
    if (schemeString) {
        scheme = [NSString stringWithCString:schemeString encoding:NSUTF8StringEncoding];
    } else {
        scheme = @"http";
    }
    
    NSString *host = @"";
    const char *hostHeader = evhttp_find_header(req->input_headers, "Host");
    if (hostHeader) {
        host = [NSString stringWithCString:hostHeader encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *fullpath = [NSMutableString stringWithCString:evhttp_uri_get_path(uri) encoding:NSUTF8StringEncoding];
    const char *queryString = evhttp_uri_get_query(uri);
    if (queryString) {
        [fullpath appendFormat:@"?%s", queryString];
    }

    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@", scheme, host, fullpath];
    request.URL = [[NSURL alloc] initWithString:urlString];
    request.method = method_for_request(req);
    request.headers = rad_request_headers_helper(req);
    request.body = rad_request_body_helper(req);
    request.context = req;
    request.server = server;
    return [server processRequest:request];
}

@implementation AgentLibEventHTTPServer
@synthesize operationQueue;

- (id)initWithService:(AgentHTTPService *) service
{
    if (self = [super initWithService:service]) {
        event_base = event_init();
        evdns_init();
        httpd = evhttp_new(event_base);
        evhttp_set_gencb(httpd, rad_request_handler, (__bridge void *)(self));
        operationQueue = [NSMutableArray array];
    }
    return self;
}

- (int) bindToAddress:(NSString *) address port:(int) port
{
    return evhttp_bind_socket(httpd, [address cStringUsingEncoding:NSUTF8StringEncoding], port);
}

static void sig_pipe(int signo)
{
    NSLog(@"SIGPIPE: lost connection during write. (signal %d)", signo);
}

struct event_base *gevent_base;

static void sig_int(int sig)
{
    signal(sig, SIG_IGN);
    event_base_loopexit(gevent_base, NULL); // exits libevent loop
}

- (void) start
{
    int status;
    if (self.localOnly) {
        status = [self bindToAddress:@"127.0.0.1" port:self.port];
    }
    else {
        status = [self bindToAddress:@"0.0.0.0" port:self.port];
    }
    if (status != 0) {
        NSLog(@"Unable to start service on port %d. Is another server running?", self.port);
    }
    else {
        gevent_base = event_base;
        signal(SIGINT, sig_int);
        
        if (signal(SIGPIPE, sig_pipe) == SIG_ERR) {
            NSLog(@"failed to setup SIGPIPE handler.");
        }
        event_base_dispatch(event_base);
    }
}

- (void) run
{
    [self start];
}

static NSDictionary *rad_response_headers_helper(struct evhttp_request *req)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    struct evkeyval *header;
    TAILQ_FOREACH(header, req->output_headers, next) {
        NSString *value = [NSString stringWithCString:header->value encoding:NSUTF8StringEncoding];
        NSString *key = [NSString stringWithCString:header->key encoding:NSUTF8StringEncoding];
        if (value && key) {
            [dict setObject:value forKey:key];
        }
    }
    return dict;
}

static void rad_response_helper(struct evhttp_request *req, AgentHTTPResponse *response)
{    
    evhttp_clear_headers(req->output_headers);
    for (id key in [response.headers allKeys]) {
        id value = [response.headers objectForKey:key];
        evhttp_add_header(req->output_headers,
                          [key cStringUsingEncoding:NSUTF8StringEncoding],
                          [value cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    struct evbuffer *buf = evbuffer_new();
    if (buf == NULL) {
        NSLog(@"FATAL: failed to create response buffer");
        assert(0);
    }
    if (req->type != EVHTTP_REQ_HEAD) {
        int result = evbuffer_add(buf, [response.body bytes], [response.body length]);
        if (result == -1) {
            NSLog(@"WARNING: failed to write %ld bytes to response buffer", (unsigned long) [response.body length]);
        }
    }
    else {
        char buffer[100];
        sprintf(buffer, "%d", (int) [response.body length]);
        evhttp_add_header(req->output_headers, "Content-Length", buffer);
    }
    evhttp_send_reply(req, response.status, "", buf);
    evbuffer_free(buf);
}

- (void)processRequest:(AgentHTTPRequest *)request
{
    if (self.verbose) {
        NSLog(@"%@ %@ %@\n%@",
              [request URL],
              [request method],
              [request path],
              [[request headers] description]
              );
    }
    @try {
        AgentHTTPResponse *response = [self.service responseForHTTPRequest:request];
        if (!response) {
            response = [[AgentHTTPResponse alloc] init];
            response.status = 404;
            response.body = [@"Resource not found" dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        struct evhttp_request *req = (struct evhttp_request *) request.context;
        if (self.verbose) {
            NSLog(@"RESPONSE %d %@", response.status, [response.headers description]);
        }
        rad_response_helper(req, response);
        if (response.exit) {
		event_base_loopexit(event_base, NULL);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error while responding to request (%@): %@", request.path, [exception reason]);
    }
}

// Support for custom events. Action handlers can use addEventWithOperation:
// to schedule longer-running actions so that they can respond more quickly to requests.
void cb_func(evutil_socket_t fd, short what, void *arg)
{
   AgentLibEventHTTPServer *server = (__bridge AgentLibEventHTTPServer *) arg;
   NSOperation *operation = [server.operationQueue objectAtIndex:0];
   [operation main];
   [server.operationQueue removeObjectAtIndex:0];
}

- (void) addEventWithOperation:(NSOperation *) operation
{
    [self.operationQueue addObject:operation];
    struct timeval zero_sec = { 0, 0 };
    struct event *ev = event_new(event_base, -1, 0, cb_func, (__bridge void *) self);
    event_add(ev, &zero_sec);
}

@end
