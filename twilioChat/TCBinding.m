//
//  TCBinding.m
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCBinding.h"

@implementation TCBinding
-(instancetype)initWithIdentity:(NSString *)identity{
    if(self = [super init]){
        _identity = identity;
        _bindingType = @"apn";
        
    }
    return self;
}
@end
