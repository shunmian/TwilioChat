//
//  TCChannel.h
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCChannel : NSObject
@property(nonatomic, strong) NSString *identity;
@property(nonatomic, strong) NSString *friendlyName;
@property(nonatomic, strong) NSString *sid;

-(instancetype)initWithIdentity:(NSString *)identity friendlyName:(NSString *)friendlyName;
@end
