//
//  TCSearchResultsViewController.h
//  twilioChat
//
//  Created by LAL on 2017/5/31.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessagesViewController.h>

@interface TCSearchResultsViewController : JSQMessagesViewController
@property(nonatomic,weak) id replacedDelegate;
@property(nonatomic,weak) id replacedDataSource;
@end
