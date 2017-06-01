//
//  ChatRoomViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/24.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "ChatRoomViewController.h"
#import <TwilioChatClient/TwilioChatClient.h>
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessage.h>
#import <UIColor+JSQMessages.h>
#import <JSQSystemSoundPlayer.h>
#import <JSQSystemSoundPlayer+JSQMessages.h>

@interface ChatRoomViewController ()
@property(nonatomic, strong) JSQMessagesBubbleImage *outgointBubbleImageView;
@property(nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageView;
@property(nonatomic, strong) UITextField *textField;
@end

@implementation ChatRoomViewController

# pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - Setter & Getter

-(NSMutableArray<TCHMessage *> *)messages{
    if(!_messages){
        _messages = [NSMutableArray new];
    }
    return _messages;
}

-(JSQMessagesBubbleImage *)outgointBubbleImageView{
    if(!_outgointBubbleImageView){
        _outgointBubbleImageView = [self setupOutgoingBubble];
    }
    return _outgointBubbleImageView;
}

-(JSQMessagesBubbleImage *)incomingBubbleImageView{
    if(!_incomingBubbleImageView){
        _incomingBubbleImageView = [self setupIncomingBubble];
    }
    return _incomingBubbleImageView;
}

-(UITextField *)textField{
    if(!_textField){
        for(UIView *view in self.view.subviews){
            if([view isKindOfClass:[UITextField class]]){
                _textField = (UITextField *)view;
                break;
            }
        }
    }
    return _textField;
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    TCHMessage *tchMessage  = (TCHMessage *)self.messages[indexPath.row];
    return [self convertFromTCHMessageToJSQMessageData:tchMessage];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.messages.count;
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message = [self convertFromTCHMessageToJSQMessageData: self.messages[indexPath.row]];
    if ([message.senderId isEqualToString: self.senderId]){
        return self.outgointBubbleImageView;
    }else{
        return self.incomingBubbleImageView;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage *message = [self convertFromTCHMessageToJSQMessageData: self.messages[indexPath.row]];
    if ([message.senderId isEqualToString:self.senderId]){
        cell.textView.textColor = [UIColor whiteColor];
    }else{
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark - Button Pressed

-(void)didPressSendButton:(UIButton *)button
          withMessageText:(NSString *)text
                 senderId:(NSString *)senderId
        senderDisplayName:(NSString *)senderDisplayName
                     date:(NSDate *)date{
    NSLog(@"return pressed");
    if(text.length == 0){
        [self.view endEditing:YES];
    }else{
        TCHMessage *message = [self.channel.messages createMessageWithBody:text];
        [self.channel.messages sendMessage:message completion:^(TCHResult *result) {
            if(!result.isSuccessful){
                NSLog(@"message not sent...");
            }else{
                NSLog(@"message sent successfully");
            }
            self.textField.text= @"";
            [self scrollToBottomAnimated:YES];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self finishSendingMessage];
        }];
    }

}

#pragma mark - helper method

-(JSQMessagesBubbleImage *)setupOutgoingBubble{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
}

-(JSQMessagesBubbleImage *)setupIncomingBubble{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

#pragma mark - TwilioChatClientDelegate

-(void)chatClient:(TwilioChatClient *)client synchronizationStatusChanged:(TCHClientSynchronizationStatus)status{
    if(status == TCHClientSynchronizationStatusCompleted){
        NSString *defaultChannel = @"general";
        [client.channelsList channelWithSidOrUniqueName:defaultChannel completion:^(TCHResult *result, TCHChannel *channel) {
            if(channel){
                self.channel = channel;
                [self.channel joinWithCompletion:^(TCHResult *result) {
                    NSLog(@"joined general channel");
                    [self.channel.messages getLastMessagesWithCount:5
                                                         completion:^(TCHResult *result, NSArray<TCHMessage *> *messages) {
                                                             for (TCHMessage *message in messages) {
                                                                 NSLog(@"Message body: %@", message.body);
                                                                 [self.messages addObject:message];
                                                             }
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [self.collectionView reloadData];
                                                             });
                                                         }];
                }];
            }else{
                //create the general channel if it hasn't been created yet
                [client.channelsList createChannelWithOptions:@{TCHChannelOptionFriendlyName:@"General Chat Chaneel", TCHChannelOptionType:@(TCHChannelTypePublic)} completion:^(TCHResult *result, TCHChannel *channel) {
                    self.channel = channel;
                    [self.channel joinWithCompletion:^(TCHResult *result) {
                        NSLog(@"channel unique name set");
                    }];
                }];
            }
            
            
        }];
        
    }
}

-(void)chatClient:(TwilioChatClient *)client channel:(TCHChannel *)channel messageAdded:(TCHMessage *)message{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.messages addObject:message];
    [self.collectionView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(JSQMessage*)convertFromTCHMessageToJSQMessageData:(TCHMessage *)tchMessage{
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:tchMessage.author
                                                senderDisplayName:tchMessage.author
                                                             date:tchMessage.timestampAsDate
                                                             text:tchMessage.body];
    return jsqMessage;
}

@end
