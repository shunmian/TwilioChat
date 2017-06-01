//
//  TCMember.h
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCUser.h"

@interface TCMember : NSObject
@property(nonatomic, strong) NSString *identity;
@property(nonatomic, strong) NSString *sid;

-(instancetype)initWithIdentity:(NSString *)identity;
@end
