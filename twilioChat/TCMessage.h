//
//  TCMessage.h
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCMessage : NSObject
@property(nonatomic, copy) NSString *sid;
@property(nonatomic, copy) NSString *from;  //TCUser identity
@property(nonatomic, copy) NSString *to;    //TCChannel identity
@property(nonatomic, copy) NSString *dateCreated;
@property(nonatomic, copy) NSString *body;
@property(nonatomic, assign) NSNumber *index;
@property(nonatomic, copy) NSString *url;

-(instancetype)initWithBody:(NSString *)body from:(NSString *)from;
@end
