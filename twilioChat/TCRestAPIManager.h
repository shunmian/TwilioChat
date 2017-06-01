//
//  TCRestAPIManager.h
//  twilioChat
//
//  Created by LAL on 2017/5/27.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit.h>
#import "TCService.h"
#import "TCUser.h"
#import "TCChannel.h"
#import "TCMember.h"
#import "TCMemberResponsed.h"
#import "TCMessage.h"
#import "TCCredential.h"
#import "TCBinding.h"
#import "TCEvent.h"



@interface TCRestAPIManager : NSObject
@property(nonatomic, strong) RKObjectManager *objectManager;
//@property(nonatomic, strong) RKObjectManager *notifyManager;

@property(nonatomic, strong) NSArray *services;
@property(nonatomic, strong) TCService *currentService;
@property(nonatomic, strong) NSArray *credentials;
@property(nonatomic, strong) TCCredential *currentCredential;
@property(nonatomic, strong) NSArray *bindings;
@property(nonatomic, assign) BOOL networkReachbility;

#pragma mark - network connecting
-(void)reAuth;
-(void)failedNetworkUIAlerting;

+(TCRestAPIManager *)sharedManager;

#pragma mark - Service

-(void)getServiceListWithCompletion:(void(^)(NSArray<TCService *>* services,BOOL success, NSError* error))completion;


#pragma mark - User

-(void)getUserListInService:(TCService *)service withCompletion:(void(^)(NSArray<TCUser *>* users,BOOL success, NSError* error))completion;

-(void)createUserWithIdentity:(NSString *)identity friendlyName:(NSString *)friendlyName withCompletion:(void(^)(TCUser *user,BOOL success, NSError* error))completion;

-(void)getUserWithIdentity:(NSString *)identity withCompletion:(void(^)(TCUser *user,BOOL success, NSError* error))completion;


#pragma mark - Channel

-(void)getChannelListWithCompletion:(void (^)(NSArray<TCChannel *>* channels, BOOL success, NSError *error))completion;

-(void)createChannelWithIdentity:(NSString *)identity
                   friendlyName:(NSString *)friendlyName
                 withCompletion:(void (^)(TCChannel *channel, BOOL success, NSError *error))completion;

-(void)getChannelWithIdentity:(NSString *)identity withCompletion:(void(^)(TCChannel *channel,BOOL success, NSError* error))completion;


#pragma mark - Members

-(void)getMemberListInChannel:(TCChannel *)channel WithCompletion:(void (^)(NSArray<TCMember *>* memebers, BOOL success, NSError *error))completion;

-(void)addUser:(TCUser *)user asMemeberInChannel:(TCChannel *)channel
WithCompletion:(void (^)(TCMember *member, BOOL success, NSError *error))completion;

-(void)getMemberInChannel:(TCChannel *)channel WithCompletion:(void (^)(TCMember * memebers, BOOL success, NSError *error))completion;

-(TCMember *)isUser:(TCUser *)user aMemberInMemberList:(NSArray *)members;

#pragma mark - Messages

-(void)getMessageListInChannel:(TCChannel *)channel WithCompletion:(void (^)(NSArray<TCMessage *>* messages, BOOL success, NSError *error))completion;

-(void)addMessage:(TCMessage *)message InChannel:(TCChannel *)channel
WithCompletion:(void (^)(TCMessage *message, BOOL success, NSError *error))completion;


#pragma mark - Subscribe Event

-(void)subscribeEvent:(TCEventType)eventType withCompletion:(void (^)(TCEvent *event, BOOL success, NSError *error))completion;


/*
#pragma mark - Credentials

-(void)getCredentialListWithCompletion:(void(^)(NSArray<TCCredential *>* credentials,BOOL success, NSError* error))completion;

#pragma mark - Binding

-(void)getBindingListWithCompletion:(void(^)(NSArray<TCBinding *>* bindings,BOOL success, NSError* error))completion;

-(void)addBindingForUser:(TCUser *)user WithCompletion:(void(^)(TCBinding * bindings,BOOL success, NSError* error))completion;
*/

@end
