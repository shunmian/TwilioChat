//
//  TCUser.h
//  twilioChat
//
//  Created by LAL on 2017/5/27.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kRoleSID = @"RL7c404b35a98448d4b7ac58ebb40c5aea";

@interface TCUser : NSObject
@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *identity;
@property (nonatomic, copy) NSString *roleSID;

-(id)initWithFriendlyName:(NSString *)friendlyName identity:(NSString *)identity;
@end
