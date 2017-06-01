//
//  TCCredential.m
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCCredential.h"

@implementation TCCredential

-(NSString *)description{
    NSString *des = [NSString stringWithFormat:@"friendlyName: %@, sid: %@",self.friendlyName, self.sid];
    return des;
}



@end
