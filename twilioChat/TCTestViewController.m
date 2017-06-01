//
//  TCTestViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/27.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCTestViewController.h"
#import "TCRestAPIManager.h"

@interface TCTestViewController ()
@property(nonatomic, strong) TCRestAPIManager *restAPIManager;
@property(nonatomic, strong) NSArray<TCService *>* services;
@property(nonatomic, strong) NSArray<TCUser *>* users;
@property(nonatomic, strong) TCUser *currentUser;
@property(nonatomic, strong) NSArray<TCChannel *>*channels;
@property(nonatomic, strong) TCChannel *currentChannel;
@property(nonatomic, strong) NSArray<TCMember *> *members;
@property(nonatomic, strong) TCMember *currentMember;
@property(nonatomic, strong) NSArray<TCMessage *> *messages;
@property(nonatomic, strong) TCMessage *currentMessage;
@property(nonatomic, strong) NSArray<TCCredential *>* credentials;
@property(nonatomic, strong) TCCredential* currentCredential;
@end

@implementation TCTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonPressed:(id)sender {
    
    [self.restAPIManager getServiceListWithCompletion:^(NSArray<TCService *>* services, BOOL success,NSError *error) {
        if(success){
            NSLog(@"service list get successful %@",services);
            self.services = services;
        }else{
            NSLog(@"service list get fail:%@",error);
        }
    }];
    

}

- (IBAction)userListBTNPressed:(id)sender {
    [self.restAPIManager getUserListInService:self.services[0] withCompletion:^(NSArray<TCUser *> *users, BOOL success, NSError *error) {
        if(success){
            NSLog(@"user list get successful %@",users);
            self.users = users;
        }else{
            NSLog(@"user list get fail:%@",error);
        }
    }];
}
- (IBAction)userCreateBTNPressed:(id)sender {
    [self.restAPIManager createUserWithIdentity:@"5@qq.com" friendlyName:@"Jonson" withCompletion:^(TCUser *user, BOOL success, NSError *error) {
        if(success){
            self.currentUser = user;
        }else{
            NSLog(@"%@",error);
        }
    }];
}

- (IBAction)userGetBTNPressed:(id)sender {
    [self.restAPIManager getUserWithIdentity:@"5@qq.com" withCompletion:^(TCUser *user, BOOL success, NSError *error) {
        if(success){
            NSLog(@"%@",user);
            self.currentUser = user;
        }else{
            NSLog(@"%@",error);
        }
    }];
}

-(TCRestAPIManager *)restAPIManager{
    if(!_restAPIManager){
        _restAPIManager = [TCRestAPIManager sharedManager];
    }
    return _restAPIManager;
}


- (IBAction)getChannelsBTNPressed:(id)sender {
    [self.restAPIManager getChannelListWithCompletion:^(NSArray<TCChannel *> *channels, BOOL success, NSError *error) {
        if(success){
            self.channels = channels;
        }else{
            NSLog(@"%@",error);
        }
    }];
}


- (IBAction)createChannelBTNPressed:(id)sender {
    [self.restAPIManager createChannelWithIdentity:@"testChannel1" friendlyName:@"general2" withCompletion:^(TCChannel *channel, BOOL success, NSError *error) {
        if(success){
            NSLog(@"%@",channel);
        }else{
            NSLog(@"%@",error);
        }
    }];
}

- (IBAction)getChannelBTNPressed:(id)sender {
    [self.restAPIManager getChannelWithIdentity:@"general" withCompletion:^(TCChannel *channel, BOOL success, NSError *error) {
        if(success){
            NSLog(@"%@",channel);
            self.currentChannel = channel;
        }else{
            NSLog(@"%@",error);
        }
    }];
}

- (IBAction)getMemberListBTNPressed:(id)sender {
    [self.restAPIManager getMemberListInChannel:self.currentChannel
                                 WithCompletion:^(NSArray<TCMember *> *members, BOOL success, NSError *error) {
                                     if(success){
                                         self.members =members;
                                     }else{
                                         NSLog(@"%@",error);
                                     }
    }];
    
}

- (IBAction)addMemeberBTNPressed:(id)sender {
    NSLog(@"current user:%@",self.currentUser);
    [self.restAPIManager addUser:self.currentUser asMemeberInChannel:self.currentChannel WithCompletion:^(TCMember *member, BOOL success, NSError *error) {
        if(success){
            NSLog(@"member: %@ added to channel: %@",member,self.currentChannel);
        }else{
            NSLog(@"%@",error);
        }
    }];
}

- (IBAction)getMemberBTNPressed:(id)sender {
    
}


- (IBAction)getMessagesBTNPressed:(id)sender {
    [self.restAPIManager getMessageListInChannel:self.currentChannel WithCompletion:^(NSArray<TCMessage *> *messages, BOOL success, NSError *error) {
        if(success){
            self.messages = messages;
        }else{
            NSLog(@"%@",error);
        }
    }];
}


- (IBAction)createMessageBTNPressed:(id)sender {
    NSString *body = @"message Test2";
    NSString *from = @"5@qq.com";
    
    TCMessage *message = [[TCMessage alloc] initWithBody:body from:from];
    
    [self.restAPIManager addMessage:message InChannel:self.currentChannel WithCompletion:^(TCMessage *message, BOOL success, NSError *error) {
        if(success){
            self.currentMessage = message;
        }else{
            NSLog(@"%@",error);
        }
    }];
}


- (IBAction)getMessage:(id)sender {
    
    
}

- (IBAction)getCredentialsBTNPressed:(id)sender {
//    [self.restAPIManager getCredentialListWithCompletion:^(NSArray<TCCredential *> *credentials, BOOL success, NSError *error) {
//        if(success){
//            self.credentials = credentials;
//            self.currentCredential = credentials[0];
//        }else{
//            NSLog(@"%@",error);
//        }
//    }];
}
- (IBAction)addEvent:(id)sender {
    [self.restAPIManager subscribeEvent:TCEventMessageSent withCompletion:^(TCEvent *event, BOOL success, NSError *error) {
        if(success){
            NSLog(@"event sent subscribe success");
        }else{
            NSLog(@"event sent subscribe fail");
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
