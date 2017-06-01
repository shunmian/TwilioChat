//
//  TCRestAPIManager.m
//  twilioChat
//
//  Created by LAL on 2017/5/27.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCRestAPIManager.h"
#import <AFNetworking.h>

#define kAcountSID @"ACaad8ab53047c6a94a4145900c57607c3"
#define kAuthToken @"75c0ca119d1a5bda1f2a0598893fa8c3"

static NSString *const baseChatURL = @"https://chat.twilio.com";
//static NSString *const baseNotifyURL = @"https://notify.twilio.com";
static NSString *const serviceSID = @"IS276d698362e2479096001348ed88af10";

@interface TCRestAPIManager()
@property(nonatomic, strong) NSDictionary *eventDict;
@end

@implementation TCRestAPIManager


-(NSDictionary *)eventDict{
    if(!_eventDict){
        _eventDict = @{@(TCEventMessageSend):@"onMessageSend",
                       @(TCEventMessageSent):@"onMessageSent"};
    }
    return _eventDict;
}


+(TCRestAPIManager *)sharedManager{
    static TCRestAPIManager * _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        
        //add objectManager
        NSURL *chatUrl = [NSURL URLWithString:baseChatURL];
        AFRKHTTPClient *chatHttpClient = [[AFRKHTTPClient alloc] initWithBaseURL:chatUrl];
        _sharedManager.objectManager = [[RKObjectManager alloc] initWithHTTPClient:chatHttpClient];
        [_sharedManager.objectManager.HTTPClient setAuthorizationHeaderWithUsername:kAcountSID password:kAuthToken];
            //add reachability
        
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"No Internet Connection");
                    _sharedManager.networkReachbility = NO;
                    [_sharedManager failedNetworkUIAlerting];
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    NSLog(@"WIFI");
                    _sharedManager.networkReachbility = YES;
                    [_sharedManager reAuth];
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"3G");
                    _sharedManager.networkReachbility = YES;
                    [_sharedManager reAuth];
                    break;
                default:
                    NSLog(@"Unkown network status");
                    [_sharedManager failedNetworkUIAlerting];
                    _sharedManager.networkReachbility = NO;
                    break;
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
            //add service descriptor
        RKObjectMapping *serviceMapping = [RKObjectMapping mappingForClass:[TCService class]];
        [serviceMapping addAttributeMappingsFromArray:@[@"sid"]];
        
        
        RKResponseDescriptor *serviceResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:serviceMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:@"/v2/Services"
                                                    keyPath:@"services"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [_sharedManager.objectManager addResponseDescriptor:serviceResponseDescriptor];
        
        
//        //add notifyManager
//        NSURL *notifyUrl = [NSURL URLWithString:baseChatURL];
//        AFRKHTTPClient *notifyHttpClient = [[AFRKHTTPClient alloc] initWithBaseURL:notifyUrl];
//        _sharedManager.notifyManager = [[RKObjectManager alloc] initWithHTTPClient:notifyHttpClient];
//        [_sharedManager.notifyManager.HTTPClient setAuthorizationHeaderWithUsername:kAcountSID password:kAcountSID];
//        
            //add notify descriptor
        RKObjectMapping *credentialMapping = [RKObjectMapping mappingForClass:[TCCredential class]];
        [credentialMapping addAttributeMappingsFromDictionary:@{@"sid":@"sid",
                                                                @"friendly_name":@"friendlyName",
                                                                @"type":@"type",
                                                                @"url":@"url"}];
        RKResponseDescriptor *credentailResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:credentialMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:@"/v2/Credentials"
                                                    keyPath:@"credentials"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
         [_sharedManager.objectManager addResponseDescriptor:credentailResponseDescriptor];
    });
    return _sharedManager;
}


-(void)getServiceListWithCompletion:(void(^)(NSArray<TCService *>* services,BOOL success, NSError* error))completion{
    [self.objectManager getObjectsAtPath:@"/v2/Services"
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCService *>* services = mappingResult.array;
                                     self.services = services;
                                     self.currentService = self.services[1];
                                     NSLog(@"services list getting successful %@",services);
                                     completion(services,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"services list getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];
}

-(void)getUserListInService:(TCService *)service withCompletion:(void (^)(NSArray<TCUser *> *, BOOL, NSError *))completion{
    //add user descriptor
    static dispatch_once_t onceToken;
    NSString *userPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@",service.sid,@"Users"];
    dispatch_once(&onceToken, ^{
        RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[TCUser class]];
        [userMapping addAttributeMappingsFromDictionary:@{@"friendly_name":@"friendlyName",
                                                          @"identity":@"identity",
                                                          @"roleSID":@"RoleSid"}];
        RKResponseDescriptor *serviceResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:userPathPattern
                                                    keyPath:@"users"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:serviceResponseDescriptor];
    });
    
    NSDictionary *param = @{@"PageSize":@200};
    
    [self.objectManager getObjectsAtPath:userPathPattern
                              parameters:param
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCUser *>* users = mappingResult.array;
                                     NSLog(@"user list getting successful %@",users);
                                     completion(users,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"user list getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];
}

-(void)createUserWithIdentity:(NSString *)identity
                friendlyName:(NSString *)friendlyName
              withCompletion:(void (^)(TCUser *user, BOOL success, NSError *error))completion{
    
    NSString *userPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@",(TCService *)self.currentService.sid,@"Users"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping]; //dictionary class
        [requestMapping addAttributeMappingsFromDictionary:@{@"friendlyName":@"FriendlyName",
                                                             @"identity":@"Identity"}];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[TCUser class] rootKeyPath:nil method:RKRequestMethodAny];

        [self.objectManager addRequestDescriptor:requestDescriptor];
        
        
        
        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[TCUser class]];
        [responseMapping addAttributeMappingsFromDictionary:@{@"friendly_name":@"friendlyName",
                                                              @"identity":@"identity"}];
        
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:userPathPattern
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:201]];

        [self.objectManager addResponseDescriptor:responseDescriptor];
        
    });
    
    TCUser *user = [[TCUser alloc] initWithFriendlyName:friendlyName identity:identity];
    
    [self.objectManager postObject:user path:userPathPattern parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        TCUser *userResponsed = mappingResult.array[0];
        NSLog(@"create user successfull: %@",userResponsed);
        completion(userResponsed,YES,nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"create user fail");
        completion(nil,NO,error);
    }];
}

-(void)getUserWithIdentity:(NSString *)identity
            withCompletion:(void (^)(TCUser *user, BOOL success, NSError *error))completion{
    
    static dispatch_once_t onceToken;
    NSString *userPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@/%@",self.currentService.sid,@"Users",identity];
    
    dispatch_once(&onceToken, ^{
        RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[TCUser class]];
        [userMapping addAttributeMappingsFromDictionary:@{@"friendly_name":@"friendlyName",
                                                          @"identity":@"identity",
                                                          @"roleSID":@"RoleSid"}];
        RKResponseDescriptor *serviceResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:userPathPattern
                                                    keyPath:@""
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:serviceResponseDescriptor];
    });
    
    [self.objectManager getObjectsAtPath:userPathPattern
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCUser *>* users = mappingResult.array;
                                     TCUser *user = users[0];
                                     NSLog(@"user getting successful %@",user);
                                     completion(user,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"user getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];
}

#pragma mark - Channel Operation

-(void)getChannelListWithCompletion:(void (^)(NSArray<TCChannel *>* channels, BOOL success, NSError *error))completion{
    
    //add channel descriptor
    static dispatch_once_t onceToken;
    NSString *channelPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@",self.currentService.sid,@"Channels"];
    
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *channelMapping = [RKObjectMapping mappingForClass:[TCChannel class]];
        [channelMapping addAttributeMappingsFromDictionary:@{@"friendly_name":@"friendlyName",
                                                             @"unique_name":@"identity",
                                                             @"sid":@"sid"}];
        
        RKResponseDescriptor *serviceResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:channelMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:channelPathPattern
                                                    keyPath:@"channels"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:serviceResponseDescriptor];
//    });
    
    NSDictionary *param = @{@"PageSize":@200};
    
    [self.objectManager getObjectsAtPath:channelPathPattern
                              parameters:param
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCChannel *>* channels = mappingResult.array;
                                     NSLog(@"channel list getting successful %@",channels);
                                     completion(channels,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"channel list getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];

}

-(void)createChannelWithIdentity:(NSString *)identity
                   friendlyName:(NSString *)friendlyName
                 withCompletion:(void (^)(TCChannel *, BOOL, NSError *))completion{
    
    NSString *channelPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@",(TCService *)self.currentService.sid,@"Channels"];
    
    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping]; //dictionary class
        [requestMapping addAttributeMappingsFromDictionary:@{@"identity":@"UniqueName",
                                                             @"friendlyName":@"FriendlyName"}];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[TCChannel class] rootKeyPath:nil method:RKRequestMethodAny];
        
        [self.objectManager addRequestDescriptor:requestDescriptor];
        
        
        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[TCChannel class]];
        [responseMapping addAttributeMappingsFromDictionary:@{@"friendly_name":@"friendlyName",
                                                              @"unique_name":@"identity",
                                                              @"sid":@"sid"}];
        
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:channelPathPattern
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:201]];
        
        [self.objectManager addResponseDescriptor:responseDescriptor];
        
//    });
    
    TCChannel *channel = [[TCChannel alloc] initWithIdentity:identity friendlyName:friendlyName];
    
    [self.objectManager postObject:channel path:channelPathPattern parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        TCChannel *channelResponsed = mappingResult.array[0];
        NSLog(@"create channel successfull: %@",channel);
        completion(channelResponsed,YES,nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"create user fail");
        completion(nil,NO,error);
    }];

}


-(void)getChannelWithIdentity:(NSString *)identity
               withCompletion:(void(^)(TCChannel *channel,BOOL success, NSError* error))completion;{
    static dispatch_once_t onceToken;
    NSString *channelPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@/%@",self.currentService.sid,@"Channels",identity];
    
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *channelMapping = [RKObjectMapping mappingForClass:[TCChannel class]];
        [channelMapping addAttributeMappingsFromDictionary:@{@"friendly_name":@"friendlyName",
                                                             @"unique_name":@"identity",
                                                             @"sid":@"sid"}];
        RKResponseDescriptor *serviceResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:channelMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:channelPathPattern
                                                    keyPath:@""
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:serviceResponseDescriptor];
//    });
    
    [self.objectManager getObjectsAtPath:channelPathPattern
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCChannel *>* channels = mappingResult.array;
                                     TCChannel *channel = channels[0];
                                     NSLog(@"channel getting successful %@",channel);
                                     completion(channel,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"channel getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];

}

#pragma mark - Memebers

-(void)getMemberListInChannel:(TCChannel *)channel
               WithCompletion:(void (^)(NSArray<TCMember *> *, BOOL, NSError *))completion{

    //add member descriptor
    
    NSString *memberPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@/%@/%@",self.currentService.sid,@"Channels",channel.sid,@"Members"];
    
    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *memberMapping = [RKObjectMapping mappingForClass:[TCMember class]];
        [memberMapping addAttributeMappingsFromDictionary:@{@"identity":@"identity",
                                                              @"sid":@"sid"}];;
        
        RKResponseDescriptor *memberResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:memberMapping
                                                     method:RKRequestMethodGET
                                                pathPattern:memberPathPattern
                                                    keyPath:@"members"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:memberResponseDescriptor];
//    });

 
    
    NSDictionary *param = @{@"PageSize":@200};
    
    [self.objectManager getObjectsAtPath:memberPathPattern
                              parameters:param
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCMember *>* members = mappingResult.array;
                                     NSLog(@"member list getting successful %@",members);
                                     completion(members,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"member list getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];
}

-(void)addUser:(TCUser *)user asMemeberInChannel:(TCChannel *)channel
            WithCompletion:(void (^)(TCMember *member, BOOL success, NSError *error))completion{
    NSString *memberPathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@/%@/%@",self.currentService.sid,@"Channels",channel.sid,@"Members"];
    
    TCMemberResponsed *member = [[TCMemberResponsed alloc] initWithIdentity:user.identity];
    
    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping]; //dictionary class
        [requestMapping addAttributeMappingsFromDictionary:@{@"identity":@"Identity"}];
        
        
        
        RKRequestDescriptor *requestDescriptor =
        [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                              objectClass:[TCMemberResponsed class] rootKeyPath:nil method:RKRequestMethodPOST];
        
        [self.objectManager addRequestDescriptor:requestDescriptor];
        
        
        RKObjectMapping *memberMapping = [RKObjectMapping mappingForClass:[TCMemberResponsed class]];
        [memberMapping addAttributeMappingsFromDictionary:@{@"identity":@"identity",
                                                            @"sid":@"sid"}];;
        
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:memberMapping
                                                     method:RKRequestMethodPOST
                                                pathPattern:memberPathPattern
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:201]];
        
        [self.objectManager addResponseDescriptor:responseDescriptor];
//    });
    
    [self getMemberListInChannel:channel WithCompletion:^(NSArray<TCMember *> *memebers, BOOL success, NSError *error) {
        if(success){
            TCMember *memberResponsed = [self isUser:user aMemberInMemberList:memebers];
            if(memberResponsed){
                NSLog(@"user: %@ already a member in channel: %@",user.identity,channel.identity);
                completion(memberResponsed,YES,nil);
            }else{
                NSLog(@"not a member yet");
                [self.objectManager postObject:member
                                          path:memberPathPattern
                                    parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                        TCMemberResponsed *memberResponsed = mappingResult.array[0];
                                        NSLog(@"add member successfull: %@",memberResponsed);
                                        completion(memberResponsed,YES,nil);
                                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                        NSLog(@"add member fail");
                                        completion(nil,NO,error);
                                    }];
            }
        }else{
            NSLog(@"get member list fail when adding user");
        }
    }];
}

-(TCMember *)isUser:(TCUser *)user aMemberInMemberList:(NSArray *)members{
    for(TCMember *member in members){
        if([user.identity isEqualToString:member.identity]){
            return member;
        }
    }
    return nil;
}

#pragma marlk - Message

-(void)getMessageListInChannel:(TCChannel *)channel
                WithCompletion:(void (^)(NSArray<TCMessage *>* messages, BOOL success, NSError *error))completion{
    //add message descriptor
    static dispatch_once_t onceToken;
    NSString *messagePathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@/%@/%@",self.currentService.sid,@"Channels",channel.sid,@"Messages"];
    
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *messageMapping = [RKObjectMapping mappingForClass:[TCMessage class]];
        [messageMapping addAttributeMappingsFromDictionary:@{@"sid":@"sid",
                                                             @"from":@"from",
                                                             @"to":@"to",
                                                             @"date_created":@"dateCreated",
                                                             @"body":@"body",
                                                             @"index":@"index",
                                                             @"url":@"url"}];
        
        RKResponseDescriptor *memberResponseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:messageMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:messagePathPattern
                                                    keyPath:@"messages"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:memberResponseDescriptor];
//    });
    
    NSDictionary *param = @{@"PageSize":@200};
    
    [self.objectManager getObjectsAtPath:messagePathPattern
                              parameters:param
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCMessage *>* messages = mappingResult.array;
                                     NSLog(@"message list getting successful %@",messages);
                                     completion(messages,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"message list getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];
    
}

-(void)addMessage:(TCMessage *)message InChannel:(TCChannel *)channel WithCompletion:(void (^)(TCMessage *, BOOL, NSError *))completion{
    NSString *messagePathPattern = [NSString stringWithFormat:@"/v2/Services/%@/%@/%@/%@",self.currentService.sid,@"Channels",channel.sid,@"Messages"];
    
    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping]; //dictionary class
        [requestMapping addAttributeMappingsFromDictionary:@{@"body":@"Body",
                                                             @"from":@"From"}];
        
        
        
        RKRequestDescriptor *requestDescriptor =
        [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                              objectClass:[TCMessage class] rootKeyPath:nil method:RKRequestMethodAny];
        
        [self.objectManager addRequestDescriptor:requestDescriptor];
        
        
        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[TCMessage class]];
        [responseMapping addAttributeMappingsFromDictionary:@{@"sid":@"sid",
                                                              @"from":@"from",
                                                              @"to":@"to",
                                                              @"date_created":@"dateCreated",
                                                              @"body":@"body",
                                                              @"index":@"index",
                                                              @"url":@"url"}];
        
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:messagePathPattern
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:201]];
        
        [self.objectManager addResponseDescriptor:responseDescriptor];
        
//    });
    
    [self.objectManager postObject:message
                              path:messagePathPattern
                        parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            TCMessage *messageResponsed = mappingResult.array[0];
                            NSLog(@"add message successfull: %@",messageResponsed);
                            completion(messageResponsed,YES,nil);
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            NSLog(@"add message fail");
                            completion(nil,NO,error);
                        }];
}

#pragma mark - Subscribe Event

-(void)subscribeEvent:(TCEventType)eventType withCompletion:(void (^)(TCEvent *event, BOOL success, NSError *error))completion{

    NSString *eventTypeString = self.eventDict[@(eventType)];
    TCEvent *event = [[TCEvent alloc] initWithEventType:eventTypeString];
    
    NSString *eventPathPattern = [NSString stringWithFormat:@"/v2/Services/%@",self.currentService.sid];
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping]; //dictionary class
        [requestMapping addAttributeMappingsFromDictionary:@{@"eventTypeString":@"WebhookFilters"}];
        
        
        RKRequestDescriptor *requestDescriptor =
        [RKRequestDescriptor requestDescriptorWithMapping:requestMapping
                                              objectClass:[TCEvent class]
                                              rootKeyPath:nil
                                                   method:RKRequestMethodAny];
        
        [self.objectManager addRequestDescriptor:requestDescriptor];
        
        
        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[TCEvent class]];
        [responseMapping addAttributeMappingsFromDictionary:@{@"date_created":@"dateCreated"}];
        
        RKResponseDescriptor *responseDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                     method:RKRequestMethodAny
                                                pathPattern:eventPathPattern
                                                    keyPath:nil
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
        
        [self.objectManager addResponseDescriptor:responseDescriptor];
        
    });
    
    [self.objectManager postObject:event
                              path:eventPathPattern
                        parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            TCEvent *eventResponsed = mappingResult.array[0];
                            NSLog(@"add event successfull: %@",eventResponsed);
                            completion(eventResponsed,YES,nil);
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            NSLog(@"add event fail");
                            completion(nil,NO,error);
                        }];
}

/*

#pragma mark - Credentails

-(void)getCredentialListWithCompletion:(void (^)(NSArray<TCCredential *> *, BOOL, NSError *))completion{
    [self.objectManager getObjectsAtPath:@"/v2/Credentials"
                              parameters:nil
                                 success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     NSArray<TCCredential *>* credentials = mappingResult.array;
                                     self.credentials = credentials;
                                     self.currentCredential = self.credentials[0];
                                     NSLog(@"credential list getting successful %@",credentials);
                                     completion(credentials,YES,nil);
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     NSLog(@"credential list getting error: %@",error);
                                     completion(nil,NO,error);
                                 }];
}


#pragma mark - Bindings

-(void)getBindingListWithCompletion:(void (^)(NSArray<TCBinding *> *, BOOL, NSError *))completion{

}

-(void)addBindingForUser:(TCUser *)user WithCompletion:(void (^)(TCBinding *, BOOL, NSError *))completion{
    
}
 */

#pragma mark - Helper

-(void)failedNetworkUIAlerting{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"No Network Connection"
                          message:@"Please Check Your Network Connectivity"
                          delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK",nil];
    // 显示
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

-(void)reAuth{
    [self getServiceListWithCompletion:^(NSArray<TCService *> *services, BOOL success, NSError *error) {
        if(success){
            
        }else{
            
        }
    }];
}

@end
