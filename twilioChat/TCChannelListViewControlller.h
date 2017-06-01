//
//  TCChannelViewControlller.h
//  
//
//  Created by LAL on 2017/5/28.
//
//

#import <UIKit/UIKit.h>
#import "TCUser.h"

@interface TCChannelListViewControlller : UITableViewController
@property(nonatomic, strong) TCUser *user;
@property(nonatomic, strong) NSArray<TCUser *>* users;
@end
