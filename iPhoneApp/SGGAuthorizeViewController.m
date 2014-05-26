//
//  SGGAuthorizeViewController.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 16.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGAuthorizeViewController.h"

@implementation SGGAuthorizeViewController

static NSArray *SCOPE = nil;

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self startWorking];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
	[[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self startWorking];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    NSLog(@"LOL");
}
- (IBAction)authorizeVK:(id)sender {
    [VKSdk authorize:SCOPE revokeAccess:YES forceOAuth:YES];
    if ([VKSdk wakeUpSession]) {
        [self startWorking];
    } else {
        
    }
}


- (void)startWorking {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SGGMainGraphController *mainViewController = [storyBoard instantiateViewControllerWithIdentifier:@"SGGMainGraphController"];
    mainViewController.countOfFingers.text = [[VKSdk getAccessToken] accessToken];
    UIWindow *frontWindow = [[[UIApplication sharedApplication] windows]
                             lastObject];
    [frontWindow setRootViewController:mainViewController];
}

- (void)viewDidLoad {
    SCOPE = @[VK_PER_FRIENDS];
	[super viewDidLoad];
    
	[VKSdk initializeWithDelegate:self andAppId:@"4193213"];
    
}

@end
