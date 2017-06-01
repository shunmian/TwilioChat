//
//  TCSearchResultsViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/31.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCSearchResultsViewController.h"


@implementation TCSearchResultsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.collectionView.delegate = self.replacedDelegate;
    self.collectionView.dataSource = self.replacedDataSource;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.inputToolbar.frame = CGRectMake(0, 0, 0, 0);
}





@end
