//
//  TCEvent.h
//  twilioChat
//
//  Created by LAL on 2017/5/29.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TCEventType){
    TCEventMessageSend = 0,
    TCEventMessageSent
};

@interface TCEvent : NSObject
@property(nonatomic, copy) NSString *eventTypeString;
@property(nonatomic, copy) NSString *dateCreated;

-(instancetype)initWithEventType:(NSString *)eventTypeString;
@end
