//
//  TCMessage.m
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCMessage.h"

@implementation TCMessage


-(instancetype)initWithBody:(NSString *)body
                       from:(NSString *)from{
    if(self = [super init]){
        _body = body;
        _from = from;
    }
    return self;
}


-(NSString *)description{
    NSString *des = [NSString stringWithFormat:@"from: %@, to: %@, body: %@, date:%@",self.from,self.to, self.body, self.dateCreated];
    return des;
}

@end
