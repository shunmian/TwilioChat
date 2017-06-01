//
//  ChatTableViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/24.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "ChatTableViewController.h"
#import <TwilioChatClient/TwilioChatClient.h>
#import <Masonry.h>

@interface ChatTableViewController ()<UITableViewDataSource,UITabBarDelegate,TwilioChatClientDelegate,UITextFieldDelegate>

@property(nonatomic, strong) NSString *identity;
@property(nonatomic, strong) NSMutableArray *messages;
@property(nonatomic, strong) TCHChannel *channel;
@property(nonatomic, strong) TwilioChatClient *client;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation ChatTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.textField.delegate = self;
    
    NSLog(@"%@",self.client);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *tokenEndpoint = @"http://0272ed51.ngrok.io/token.php?device=%@";
    NSString *urlString = [NSString stringWithFormat:tokenEndpoint,deviceID];
    
    //Make JSON request to server
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSError *jsonError;
            NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:&jsonError];
            /*tokenResponse = !@{@"identity":@"Jim",
             @"token"   :@"97sdf98sdu98fdhffewkr"}
             */
            if(!jsonError){
                self.identity = tokenResponse[@"identity"];
                NSString *token = tokenResponse[@"token"];
                _client = [TwilioChatClient chatClientWithToken:token properties:nil delegate:self];

                NSLog(@"tokenResponse: %@",tokenResponse);
                
//                [[self.client channelsList] publicChannelsWithCompletion:^(TCHResult *result, TCHChannelDescriptorPaginator *paginator) {
//                    if([result isSuccessful]){
//                        for (TCHChannelDescriptor *channel in paginator.items){
//                            NSLog(@"Channel public:%@",channel.friendlyName);
//                        }
//                    }
//                }];
//                
//                [[self.client channelsList] userChannelsWithCompletion:^(TCHResult *result, TCHChannelPaginator *paginator) {
//                    if([result isSuccessful]){
//                        for (TCHChannelDescriptor *channel in paginator.items){
//                            NSLog(@"Channel user:%@",channel.friendlyName);
//                        }
//                    }
//                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationItem.prompt = [NSString stringWithFormat:@"Logged in as %@",self.identity];
                    [self.tableView reloadData];
                });
            }else{
                NSLog(@"ViewController viewDidLoad: error parsing token from server");
            }
        }else{
            NSLog(@"ViewController viewDidLoad: error fetching token from server");
        }
    }];
    [dataTask resume];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    CGFloat topOffset = [self offsetHeightFromStatusBarAndNavigationBar];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tableView.superview.mas_left).with.offset(0);
        make.right.equalTo(self.tableView.superview.mas_right).with.offset(0);
        make.top.equalTo(self.tableView.superview.mas_top).with.offset(0);
        make.bottom.equalTo(self.tableView.superview.mas_bottom).with.offset(0);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textField.superview.mas_left).with.offset(0);
        make.right.equalTo(self.textField.superview.mas_right).with.offset(0);
        make.bottom.equalTo(self.textField.superview.mas_bottom).with.offset(0);
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter & Getter

-(NSMutableArray *)messages{
    if(!_messages){
        _messages = [NSMutableArray new];
    }
    return _messages;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    
    TCHMessage *message = self.messages[indexPath.row];
    NSLog(@"cell: %@",message);
    cell.detailTextLabel.text = message.author;
    cell.textLabel.text = message.body;
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"return pressed");
    if(textField.text.length == 0){
        [self.view endEditing:YES];
    }else{
        TCHMessage *message = [self.channel.messages createMessageWithBody:textField.text];
        textField.text = @"";
        [self.channel.messages sendMessage:message completion:^(TCHResult *result) {
            [textField resignFirstResponder];
            if(!result.isSuccessful){
                NSLog(@"message not sent...");
            }
        }];
    
    }
    return YES;
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
                                                                 [self.tableView reloadData];
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
    [self.tableView reloadData];
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(CGFloat)offsetHeightFromStatusBarAndNavigationBar{
    return self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
