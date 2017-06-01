//
//  ChatRoomViewController.h
//  twilioChat
//
//  Created by LAL on 2017/5/24.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <TwilioChatClient/TCHChannel.h>
#import <TwilioChatClient/TCHMessage.h>
#import <TwilioChatClient/TwilioChatClient.h>


@interface ChatRoomViewController : JSQMessagesViewController<TwilioChatClientDelegate>
@property(nonatomic, strong) NSMutableArray<TCHMessage *> *messages;
@property(nonatomic, strong) TCHChannel *channel;
@property(nonatomic, strong) TwilioChatClient *client;

@end
