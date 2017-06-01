//
//  TCEvent.m
//  twilioChat
//
//  Created by LAL on 2017/5/29.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCEvent.h"

@implementation TCEvent

-(instancetype)initWithEventType:(NSString *)eventTypeString{
    if(self = [super init]){
        _eventTypeString = eventTypeString;
    }
    return self;
}

@end
