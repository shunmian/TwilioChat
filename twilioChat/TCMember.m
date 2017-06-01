//
//  TCMember.m
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCMember.h"

@implementation TCMember

-(instancetype)initWithIdentity:(NSString *)identity{
    if(self = [super init]){
        _identity = identity;
    }
    return self;
}

-(NSString *)description{
    NSString *des = [NSString stringWithFormat:@"identity: %@,sid:%@",self.identity,self.sid];
    return des;
}

@end
