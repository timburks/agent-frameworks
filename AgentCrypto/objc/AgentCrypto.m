#import "AgentCrypto.h"
#import "AgentBinaryEncoding.h"


@implementation NSString (AgentCrypto)

- (NSString *) agent_md5HashWithSalt:(NSString *) salt
{
    return [[[self dataUsingEncoding:NSUTF8StringEncoding]
      agent_hmacMd5DataWithKey:[salt dataUsingEncoding:NSUTF8StringEncoding]]
     agent_hexEncodedString];
}

@end
