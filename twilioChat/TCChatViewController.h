//
//  TChatViewController.h
//  twilioChat
//
//  Created by LAL on 2017/5/30.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "TCMessage.h"
#import "TCChannel.h"


@interface TCChatViewController : JSQMessagesViewController 
@property(nonatomic, strong) NSMutableArray<TCMessage *> *messages;
@property(nonatomic, strong) TCChannel *channel;
@end
