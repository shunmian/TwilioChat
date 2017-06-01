//
//  TCChannel.m
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCChannel.h"

@implementation TCChannel

-(instancetype)initWithIdentity:(NSString *)identity
                   friendlyName:(NSString *)friendlyName{
    if(self = [super init]){
        _identity = identity;
        _friendlyName = friendlyName;
    }
    return self;
}

-(NSString *)description{
    NSString *des = [NSString stringWithFormat:@"friendlyName: %@, identity: %@, sid: %@",self.friendlyName,self.identity,self.sid];
    return des;
}

@end
