//
//  TChatViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/30.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCChatViewController.h"
#import "TCRestAPIManager.h"
#import "TCSearchResultsViewController.h"
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessage.h>
#import <UIColor+JSQMessages.h>
#import <JSQSystemSoundPlayer.h>
#import <JSQSystemSoundPlayer+JSQMessages.h>



@interface TCChatViewController () <UITableViewDataSource,UITabBarDelegate,UITextFieldDelegate,UISearchResultsUpdating,UIGestureRecognizerDelegate>
@property(nonatomic, strong) TCRestAPIManager *restAPIManager;
@property(nonatomic, strong) JSQMessagesBubbleImage *outgointBubbleImageView;
@property(nonatomic, strong) JSQMessagesBubbleImage *incomingBubbleImageView;
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) TCSearchResultsViewController *resultController;
@property(nonatomic, strong) NSArray <TCMessage *>* searchedMessages;
@property(nonatomic, strong) NSTimer *meassageFetechTimer;

@end

@implementation TCChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.automaticallyScrollsToMostRecentMessage = YES;
    self.textView = self.inputToolbar.contentView.textView;
    self.textView.delegate = self;
    NSLog(@"view");
    //add searchViewController
    
    self.resultController = [[TCSearchResultsViewController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    self.resultController.senderId = self.senderId;
    self.resultController.senderDisplayName = self.senderId;
    self.resultController.replacedDataSource = self;
    self.resultController.replacedDelegate = self;
    self.searchController.searchResultsUpdater = self;
    

    
    
    //add search button as rightBarButtonItem
    NSLog(@"channel: %@",self.channel.identity);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchMessages)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonItemStylePlain target:self action:@selector(back)];
//    [self.navigationItem.leftBarButtonItem setTitle:@"<"];
    
    //add tap gesture to dismiss keyboard
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.collectionView addGestureRecognizer:tapGR];
    tapGR.delegate = self;
    
    [self refreshMessages];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addMessageFetchTimerWithRepeatedInterval:5];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeaMessageFetchTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(TCRestAPIManager *)restAPIManager{
    if(!_restAPIManager){
        _restAPIManager = [TCRestAPIManager sharedManager];
    }
    return _restAPIManager;
}

-(NSArray<TCMessage *> *)messages{
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


#pragma mark - Button Pressed

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshMessages{
    [self.restAPIManager getMessageListInChannel:self.channel WithCompletion:^(NSArray<TCMessage *> *messages, BOOL success, NSError *error) {
        if(success){
            if([self isMessagesChangedFrom:self.messages to:messages]){
                self.messages = messages;
                NSLog(@"gotten messages:%@",self.messages);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self scrollToMostRecentMessage];
                });
            }
        }else{
            NSLog(@"gotten messages error");
        }
    }];
}

-(void)searchMessages{
    
    //search chat history
    [self presentViewController:self.searchController animated:YES completion:nil];
}



-(void)didPressSendButton:(UIButton *)button
          withMessageText:(NSString *)text
                 senderId:(NSString *)senderId
        senderDisplayName:(NSString *)senderDisplayName
                     date:(NSDate *)date{
    NSLog(@"return pressed");
    
    if(self.restAPIManager.networkReachbility == NO){
        [self.restAPIManager failedNetworkUIAlerting];
        return;
    }
    
    if(text.length == 0){
        [self.view endEditing:YES];
    }else{
        TCMessage *message = [[TCMessage alloc] initWithBody:text from:self.senderId];
        [self.restAPIManager addMessage:message InChannel:self.channel WithCompletion:^(TCMessage *message, BOOL success, NSError *error) {
            if(success){
            NSLog(@"message sent successfully:%@",message.dateCreated);
                [self.messages addObject:message];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self scrollToMostRecentMessage];
                });
            }else{
             NSLog(@"message not sent...");
            }
            self.textView.text= @"";
            [self finishSendingMessage];
            [self scrollToBottomAnimated:YES];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            
        }];
    }
    
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    TCMessage *tcMessage;
    if(collectionView == self.collectionView){
        tcMessage  = (TCMessage *)self.messages[indexPath.row];
    }else if(collectionView == self.resultController.collectionView){
        tcMessage  = (TCMessage *)self.searchedMessages[indexPath.row];
    }
    return [self convertFromTCMessageToJSQMessageData:tcMessage];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count;
    if(collectionView == self.collectionView){
        count = self.messages.count;
    }else if(collectionView == self.resultController.collectionView){
        count = self.searchedMessages.count;
    }
    return count;
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message;
    if(collectionView == self.collectionView){
        message = [self convertFromTCMessageToJSQMessageData: self.messages[indexPath.row]];
    }else if (collectionView == self.resultController.collectionView){
        message = [self convertFromTCMessageToJSQMessageData: self.searchedMessages[indexPath.row]];
    }
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
    JSQMessage *message;
    if(collectionView == self.collectionView){
        message = [self convertFromTCMessageToJSQMessageData: self.messages[indexPath.row]];
    }else if (collectionView == self.resultController.collectionView){
        message = [self convertFromTCMessageToJSQMessageData: self.searchedMessages[indexPath.row]];
    }
    if ([message.senderId isEqualToString:self.senderId]){
        cell.textView.textColor = [UIColor whiteColor];
    }else{
        cell.textView.textColor = [UIColor blackColor];
    }
    
    return cell;
}


#pragma mark - UITextViewDelegate



//-(void)textViewDidBeginEditing:(UITextView *)textView{
//    NSLog(@"start editing");
//    [self scrollToMostRecentMessage];
//}

//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    [self scrollToMostRecentMessage];
//}

#pragma mark - helper method

-(JSQMessagesBubbleImage *)setupOutgoingBubble{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:24.0/255.0 green:169.0/255.0 blue:91.0/255.0 alpha:0.75]];
}

-(JSQMessagesBubbleImage *)setupIncomingBubble{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

-(void)addMessageFetchTimerWithRepeatedInterval:(NSTimeInterval)second{
    self.meassageFetechTimer = [NSTimer scheduledTimerWithTimeInterval:second target:self selector:@selector(refreshMessages) userInfo:nil repeats:YES];
}

-(void)removeaMessageFetchTimer{
    [self.meassageFetechTimer invalidate];
    self.meassageFetechTimer = nil;
}

-(void)scrollToMostRecentMessage{
    if(!self.messages) return;
    NSInteger last = self.messages.count-1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:last inSection:0];
    [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

#pragma mark - UIGesutureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)dismissKeyboard:(UITapGestureRecognizer*)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"taptap");
        if([self.inputToolbar.contentView.textView isFirstResponder])
            [self.inputToolbar.contentView.textView resignFirstResponder];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(JSQMessage*)convertFromTCMessageToJSQMessageData:(TCMessage *)tcMessage{
    
    NSString *dateString = [tcMessage.dateCreated substringToIndex:10];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:dateString];
    
    JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:tcMessage.from
                                                senderDisplayName:tcMessage.from
                                                             date:date
                                                             text:tcMessage.body];
    return jsqMessage;
}



#pragma mark - UISearchResultsUpdater

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.body contains[cd] %@",searchController.searchBar.text];
    self.searchedMessages = [self.messages filteredArrayUsingPredicate:pred];
    NSLog(@"searched results:%@",self.searchedMessages);
    [self.resultController.collectionView reloadData];
}

-(BOOL)isMessagesChangedFrom:(NSArray *)oldMessages to:(NSArray *)newMessages{
    if(!oldMessages || !newMessages){
        return YES;
    }else{
        return oldMessages.count == newMessages.count ? NO:YES;
    }
}


@end
