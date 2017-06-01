//
//  TCCredential.h
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCredential : NSObject
@property(nonatomic, copy) NSString *sid;
@property(nonatomic, copy) NSString *friendlyName;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *url;
@end
