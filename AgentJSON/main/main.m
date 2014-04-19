#import <Foundation/Foundation.h>
#import "AgentJSON.h"

int main (int argc, const char *argv[])
{
    @autoreleasepool {
        NSLog(@"Hello, Agent");
        NSDictionary *original = @{@"one": @1,
                                   @"two": @2,
                                   @"three": @3,
                                   @"pi": @3.1415927,
                                   @"array": @[@"zero", @"one", @"two"],
                                   @"dict": @{@"a":@"A",
                                              @"b":@"B",
                                              @"c":@"C"}};
        
        NSString *encoding = [original agent_JSONRepresentation];
        NSLog(@"%@", encoding);
        NSDictionary *decoded = [encoding agent_JSONValue];
        NSLog(@"%@", decoded);
        NSLog(@"Match? %d", [decoded isEqual:original]);
    }
    return 0;
}
