//
//  TCChannelViewControlller.m
//  
//
//  Created by LAL on 2017/5/28.
//
//

#import "TCChannelListViewControlller.h"
#import "TCRestAPIManager.h"
#import "TCChatViewController.h"

@interface TCChannelListViewControlller ()
@property(nonatomic, strong) TCRestAPIManager *restAPIManager;
@property(nonatomic, strong) TCChannel *channel;
@property(nonatomic, strong) TCUser *toUser;
@property(nonatomic, strong) NSTimer *usersFetechTimer;
@end

@implementation TCChannelListViewControlller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:self.user.identity];
    [self.restAPIManager getUserListInService:self.restAPIManager.currentService withCompletion:^(NSArray<TCUser *> *users, BOOL success, NSError *error) {
        if(success){
            self.users = [self eliminateUser:self.user fromUsers:users];
            [self.tableView reloadData];
        }else{
            NSLog(@"getting user list failed");
        }
    }];
    [self.restAPIManager getChannelListWithCompletion:^(NSArray<TCChannel *> *channels, BOOL success, NSError *error) {
        if(success){
            NSLog(@"%@",channels);
        }
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.toUser = nil;
    self.channel = nil;
    [self addChannelsFetchTimerWithRepeatedInterval:20];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeaChannelsFetchTimer];
}

-(void)addChannelsFetchTimerWithRepeatedInterval:(NSTimeInterval)second{
    self.usersFetechTimer = [NSTimer scheduledTimerWithTimeInterval:second target:self selector:@selector(refreshUsers) userInfo:nil repeats:YES];
}

-(void)removeaChannelsFetchTimer{
    [self.usersFetechTimer invalidate];
    self.usersFetechTimer = nil;
}

-(void)refreshUsers{
    [self.restAPIManager getUserListInService:self.restAPIManager.currentService withCompletion:^(NSArray<TCUser *> *users, BOOL success, NSError *error) {
        if(success){
            if([self isUsersChangedFrom:self.users to:users]){
                self.users = [self eliminateUser:self.user fromUsers:users];
                NSLog(@"gotten messages:%@",self.users);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }else{
            NSLog(@"gotten messages error");
        }
    }];
}

-(TCRestAPIManager *)restAPIManager{
    if(!_restAPIManager){
        _restAPIManager = [TCRestAPIManager sharedManager];
    }
    return _restAPIManager;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.users[indexPath.row].identity;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TCUser *toUser = self.users[indexPath.row];
    self.toUser = toUser;
    NSString *channelIdentity;
    NSComparisonResult compareResult = [self.user.identity compare:toUser.identity];
    if(compareResult == NSOrderedAscending){
        channelIdentity = [NSString stringWithFormat:@"%@vs%@",self.user.identity,toUser.identity];
    }else{
        channelIdentity = [NSString stringWithFormat:@"%@vs%@",toUser.identity,self.user.identity];
    }
    
    NSLog(@"channelIdentity: %@",channelIdentity);
    
    [self.restAPIManager getChannelWithIdentity:channelIdentity withCompletion:^(TCChannel *channel, BOOL success, NSError *error) {
        if(success){
            self.channel = channel;
            NSLog(@"channel get success: %@",channelIdentity);
            
            [self.restAPIManager addUser:self.user asMemeberInChannel:self.channel WithCompletion:^(TCMember *member, BOOL success, NSError *error) {
                if(success){
                    NSLog(@"add memeber success: %@",self.user);
                    [self.restAPIManager addUser:toUser asMemeberInChannel:self.channel WithCompletion:^(TCMember *member, BOOL success, NSError *error) {
                        if(success){
                            NSLog(@"add memeber success: %@",toUser);
                            [self performSegueWithIdentifier:@"ChannelSegue" sender:nil];
                        }else{
                            NSLog(@"add memeber fail: %@",toUser);
                        }
                    }];
                }else{
                    NSLog(@"add memeber fail: %@",self.user);
                }
            }];
        }else{
            NSLog(@"no channel exist: %@",channelIdentity);
            [self.restAPIManager createChannelWithIdentity:channelIdentity friendlyName:nil withCompletion:^(TCChannel *channel, BOOL success, NSError *error) {
                if(success){
                    self.channel = channel;
                    NSLog(@"channel create success: %@",channelIdentity);
                    [self.restAPIManager addUser:self.user asMemeberInChannel:self.channel WithCompletion:^(TCMember *member, BOOL success, NSError *error) {
                        if(success){
                            NSLog(@"add memeber success: %@",self.user);
                            [self.restAPIManager addUser:toUser asMemeberInChannel:self.channel WithCompletion:^(TCMember *member, BOOL success, NSError *error) {
                                if(success){
                                    NSLog(@"add memeber success: %@",toUser);
                                    [self performSegueWithIdentifier:@"ChannelSegue" sender:nil];
                                }else{
                                    NSLog(@"add memeber fail: %@",toUser);
                                }
                            }];
                        }else{
                            NSLog(@"add memeber fail: %@",self.user);
                        }
                    }];
                }else{
                    NSLog(@"channel create fail: %@",channelIdentity);
                }
            }];
        }
    }];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TCChatViewController *cvc = segue.destinationViewController;
    cvc.senderId = self.user.identity;
    cvc.senderDisplayName = self.user.identity;
    cvc.channel = self.channel;
    [cvc.navigationItem setTitle:self.toUser.identity];
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Helper

-(NSArray<TCUser *>*)eliminateUser:(TCUser *)user fromUsers:(NSArray *)users{
    NSMutableArray *mutableUsers = [NSMutableArray arrayWithArray:users];
    for (TCUser *tempUser in mutableUsers){
        if([user.identity isEqualToString:tempUser.identity]){
            [mutableUsers removeObject:tempUser];
            NSArray *finalUsers = [NSArray arrayWithArray:mutableUsers];
            return finalUsers;
        }
    }
    return [NSArray arrayWithArray:mutableUsers];
}

-(BOOL)isUsersChangedFrom:(NSArray *)fromUsers to:(NSArray *)toUsers{
    if(!fromUsers || !toUsers){
        return YES;
    }else{
        return fromUsers.count == toUsers.count ? NO:YES;
    }
}

@end
