//
//  LoginViewController.h
//  twilioChat
//
//  Created by LAL on 2017/5/24.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwilioChatClient/TwilioChatClient.h>
#import "TCUser.h"

@interface LoginViewController : UIViewController
@property(nonatomic, strong) TCUser *user;


@property(nonatomic, strong) TwilioChatClient *client;
@property(nonatomic, strong) NSString *senderId;
@end
