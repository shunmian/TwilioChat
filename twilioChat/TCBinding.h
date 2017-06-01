//
//  TCBinding.h
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCBinding : NSObject
@property(nonatomic, copy) NSString *identity;      //TCUser identity
@property(nonatomic, copy) NSString *bindingType;   //defaul to apn
@property(nonatomic, copy) NSString *address;       //device token

-(instancetype)initWithIdentity:(NSString *)identity;


@end
