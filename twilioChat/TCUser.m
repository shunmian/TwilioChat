//
//  TCUser.m
//  twilioChat
//
//  Created by LAL on 2017/5/27.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCUser.h"

@implementation TCUser

-(id)initWithFriendlyName:(NSString *)friendlyName
                 identity:(NSString *)identity{
    if(self = [super init]){
        _friendlyName = friendlyName;
        _identity = identity;
        _roleSID = kRoleSID;
    }
    return self;
}


-(NSString *)description{
    NSString *des = [NSString stringWithFormat:@"friendlyName: %@, identity: %@",self.friendlyName,self.identity];
    return des;
}

@end
