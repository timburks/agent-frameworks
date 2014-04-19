#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <security/pam_appl.h>
#include <security/pam_modules.h>
#include <security/pam_misc.h>
#import <Foundation/Foundation.h>

@interface AgentPAM : NSObject

@end

@implementation AgentPAM

static struct pam_response *reply;

static int function_conversation(int num_msg, const struct pam_message **msg, struct pam_response **resp, void *appdata_ptr)
{
  *resp = reply;
  return PAM_SUCCESS;
}

+ (int) authenticateUser:(NSString *) userName withPassword:(NSString *) passwordString
{
  const char *username = [userName cStringUsingEncoding:NSUTF8StringEncoding];

  const struct pam_conv local_conversation = { function_conversation, NULL };
  pam_handle_t *local_auth_handle = NULL; // this gets set by pam_start

  int retval;

  // local_auth_handle gets set based on the service
  retval = pam_start("common-auth", username, &local_conversation, &local_auth_handle);

  if (retval != PAM_SUCCESS) {
    return retval;
  }

  reply = (struct pam_response *)malloc(sizeof(struct pam_response));

  const char *password = [passwordString cStringUsingEncoding:NSUTF8StringEncoding];
  reply[0].resp = strdup(password);
  reply[0].resp_retcode = 0;

  retval = pam_authenticate(local_auth_handle, 0);

  //free(reply);
  //free(password);

  if (retval != PAM_SUCCESS) {
    return retval;
  }

  retval = pam_end(local_auth_handle, retval);

  if (retval != PAM_SUCCESS) {
    return retval;
  }

  return retval;
}
@end
