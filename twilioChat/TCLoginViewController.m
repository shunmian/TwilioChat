//
//  TCLoginViewController.m
//  twilioChat
//
//  Created by LAL on 2017/5/28.
//  Copyright © 2017年 LAL. All rights reserved.
//

#import "TCLoginViewController.h"
#import "TCRestAPIManager.h"
#import "TCChannelListViewControlller.h"
#import <Masonry.h>

@interface TCLoginViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *userIdentityTextField;
@property (nonatomic, weak) IBOutlet UIButton *loginBTN;
@property (nonatomic, strong) TCRestAPIManager *restAPIManager;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, assign) CGFloat movingDeltaY;
@property (nonatomic, assign) CGRect f;
@property (nonatomic, assign) BOOL keyBoardShowed;
@end

@implementation TCLoginViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyBoardShowed = NO;
    [self.restAPIManager reAuth];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"background2.png"].CGImage);
    
    //add tap gesture to dismiss keyboard
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tapGR];
    tapGR.delegate = self;
    
    self.userIdentityTextField.textAlignment = NSTextAlignmentCenter;
    
    
    self.userIdentityTextField.delegate = self;
    // Do any additional setup after loading the view.
    self.contentView.backgroundColor = [UIColor clearColor];
    self.loginBTN.layer.cornerRadius = self.loginBTN.frame.size.height/3;
//    self.loginBTN.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.loginBTN.layer.borderWidth = 1;
    
    
    //userIdentityTextField
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
//    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
//                                                                forKey:NSFontAttributeName];
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"strigil" attributes:attrsDictionary];
    self.userIdentityTextField.backgroundColor = [UIColor clearColor];
    NSAttributedString *str =
    [[NSAttributedString alloc] initWithString:@"Username"
                                    attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.5 alpha:1],NSFontAttributeName:font}];
    self.userIdentityTextField.attributedPlaceholder = str;
    self.userIdentityTextField.layer.borderWidth = 1;
    self.userIdentityTextField.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    self.userIdentityTextField.layer.cornerRadius = self.userIdentityTextField.frame.size.height/3;
    self.userIdentityTextField.textColor = [UIColor whiteColor];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    [self.appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.appNameLabel.superview.mas_centerX).with.offset(0);
        make.centerY.equalTo(self.appNameLabel.superview.mas_centerY).with.multipliedBy(0.4);
        ;
        make.height.equalTo(self.appNameLabel.superview.mas_height).with.multipliedBy(1.0/6.0);
        make.width.equalTo(self.appNameLabel.superview.mas_width).with.multipliedBy(1);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.superview.mas_centerX).with.offset(0);
        make.centerY.equalTo(self.contentView.superview.mas_centerY).with.multipliedBy(1.5);
;
        make.height.equalTo(self.contentView.superview.mas_height).with.multipliedBy(1.0/6.0);
        make.width.equalTo(self.contentView.superview.mas_width).with.multipliedBy(0.5);
    }];
    
    [self.userIdentityTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userIdentityTextField.superview.mas_centerY).with.multipliedBy(0.5);
        make.centerX.equalTo(self.userIdentityTextField.superview.mas_centerX).with.multipliedBy(1);
        make.width.equalTo(self.userIdentityTextField.superview.mas_width).with.multipliedBy(1);
        make.height.equalTo(self.userIdentityTextField.superview.mas_height).with.multipliedBy(0.4);
    }];
    
    [self.loginBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.loginBTN.superview.mas_centerY).with.multipliedBy(1.5);
        make.centerX.equalTo(self.loginBTN.superview.mas_centerX).with.multipliedBy(1);
        make.width.equalTo(self.userIdentityTextField.superview.mas_width).with.multipliedBy(1);
        make.height.equalTo(self.userIdentityTextField.superview.mas_height).with.multipliedBy(0.4);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.movingDeltaY = self.view.frame.size.height/3;
    self.f = self.contentView.frame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBTNPressed:(id)sender {
    if(self.restAPIManager.networkReachbility == NO){
        [self.restAPIManager failedNetworkUIAlerting];
        return;
    }
    
    [self.restAPIManager getUserWithIdentity:self.userIdentityTextField.text withCompletion:^(TCUser *user, BOOL success, NSError *error) {
        if(success){
            NSLog(@"login successful: %@",user.friendlyName);
            self.user = user;
            [self performSegueWithIdentifier:@"ChannelListSegue" sender:nil];
        }else{
            NSLog(@"no such user exist so create one");
            TCUser *user = [[TCUser alloc] initWithFriendlyName:nil identity:self.userIdentityTextField.text];
            [self.restAPIManager createUserWithIdentity:self.userIdentityTextField.text friendlyName:nil withCompletion:^(TCUser *user, BOOL success, NSError *error) {
                if(success){
                    NSLog(@"create user success: %@",user.identity);
                    self.user=user;
                    [self performSegueWithIdentifier:@"ChannelListSegue" sender:nil];
                }else{
                    NSLog(@"create user fail: %@",user.identity);
                }
            }];
        }
    }];
}

#pragma mark - Setter & Getter

-(TCRestAPIManager *)restAPIManager{
    if(!_restAPIManager){
        _restAPIManager = [TCRestAPIManager sharedManager];
    }
    return _restAPIManager;
}

#pragma mark - Helper

- (void)keyboardWillShow:(NSNotification *)notification{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGFloat deltaY = 40;
//    self.movingDeltaY = self.view.frame.size.height - CGRectGetMaxY(self.contentView.frame) - (keyboardSize.height + deltaY);
//    
//    if(self.movingDeltaY < 0){
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect f = self.contentView.frame;
//            f.origin.y -= -self.movingDeltaY;
//            self.contentView.frame = f;
//        }];
//    }
    if(!self.keyBoardShowed){
        self.keyBoardShowed = YES;
        NSLog(@"keyboardwillshow");
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                CGRect tempf = self.f;
                tempf.origin.y -= self.movingDeltaY;
                self.f = tempf;
                self.contentView.frame = self.f;
            }];
        });
    }

}

-(void)keyboardWillHide:(NSNotification *)notification{
    if(self.keyBoardShowed){
        self.keyBoardShowed = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                CGRect tempf = self.f;
                tempf.origin.y += self.movingDeltaY;
                self.f = tempf;
                self.contentView.frame = self.f;
            }];
        });
    }
}

#pragma mark - UIGesutureRecognizerDelegate

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}

-(void)dismissKeyboard:(UITapGestureRecognizer*)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"taptap");
        CGPoint point = [recognizer locationInView:self.view];
        if(!CGRectContainsPoint(self.contentView.frame, point))
            [self.userIdentityTextField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
//    [textField becomeFirstResponder];
    textField.placeholder = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navc = [segue destinationViewController];
    TCChannelListViewControlller *tccvc = navc.viewControllers[0];
    tccvc.user = self.user;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
