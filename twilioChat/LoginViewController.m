//
//  LoginViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/24.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatRoomViewController.h"
#import <AFNetworking.h>

#define kAcountSID @"ACaad8ab53047c6a94a4145900c57607c3"
#define kAuthToken @"75c0ca119d1a5bda1f2a0598893fa8c3"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - LifeCycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginBTNPressed:(id)sender {
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSString *tokenEndpoint = @"http://0272ed51.ngrok.io/token.php?device=%@";
//    NSString *urlString = [NSString stringWithFormat:tokenEndpoint,deviceID];
//    
//    //Make JSON request to server
//    NSURL *url = [NSURL URLWithString:urlString];
    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(data){
//            NSError *jsonError;
//            NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:data
//                                                                          options:kNilOptions
//                                                                            error:&jsonError];
//            /*tokenResponse = !@{@"identity":@"Jim",
//             @"token"   :@"97sdf98sdu98fdhffewkr"}
//             */
//            if(!jsonError){
//                self.senderId = tokenResponse[@"identity"];
//                NSString *token = tokenResponse[@"token"];
//                self.client = [TwilioChatClient chatClientWithToken:token properties:nil delegate:nil];
//                NSLog(@"tokenResponse: %@",tokenResponse);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.navigationItem.prompt = [NSString stringWithFormat:@"Logged in as %@",self.senderId];
//                    [self performSegueWithIdentifier:@"ToChatRoomSegue" sender:nil];
//                });
//            }else{
//                NSLog(@"ViewController viewDidLoad: error parsing token from server");
//            }
//        }else{
//            NSLog(@"ViewController viewDidLoad: error fetching token from server");
//        }
//    }];
//    [dataTask resume];
    
    
//    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSString *accountEndpoint = [NSString stringWithFormat: @"http://0272ed51.ngrok.io/token.php"];
//    NSDictionary *param = @{@"device":deviceID};
//    
//    NSURL *accountURL = [NSURL URLWithString:accountEndpoint];
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    [manager GET:accountEndpoint parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"json: %@:%@",[responseObject class], responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"fetch error");
//    }];
    
    
//    [self.clientManager registerUserWithUsername:@"Jack" withCompletion:^(TCUser *user, BOOL success) {
//        if(success){
//            self.user = user;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.navigationItem.prompt = [NSString stringWithFormat:@"Logged in as %@",self.user.username];
//                [self performSegueWithIdentifier:@"ToChatRoomSegue" sender:nil];
//            });
//        }else{
//            NSLog(@"register user: fail");
//            self.user = nil;
//        }
//    }];

}

#pragma mark - getter & setter





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatRoomViewController *crvc = [segue destinationViewController];
    crvc.client = self.client;
    crvc.senderId = self.senderId;
    crvc.senderDisplayName = self.senderId;
    crvc.client.delegate = crvc;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
