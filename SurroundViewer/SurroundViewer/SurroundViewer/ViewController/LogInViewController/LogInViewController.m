//
//  LogInViewController.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "LogInViewController.h"
#import "SurroundDefine.h"
#import "SurroundViewer.h"
#import "ServiceHandler.h"
#import "SurroundOperate.h"
#import "ReplyHandler.h"
#import "MultiPaneViewController.h"
#import "AppDelegate.h"

@interface LogInViewController ()<Updater, UITextFieldDelegate>{
}

@property(nonatomic, strong) IBOutlet UITextField *userName;
@property(nonatomic, strong) IBOutlet UITextField *password;
@property(nonatomic, strong) IBOutlet UILabel *createNewAccount;
@property(nonatomic, strong) IBOutlet UIImageView *userNameSelectImgView;
@property(nonatomic, strong) IBOutlet UIImageView *passwordSelectImgView;
@property(nonatomic, strong) IBOutlet UIView *infoView;
@property (nonatomic,readwrite) BOOL isAlreadyUp;
@property (nonatomic, assign) float offset2ViewMoveUp;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelTopConstraint;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //---TapRecognizer ---//
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNewAccountTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.createNewAccount addGestureRecognizer:tapGestureRecognizer];
    self.createNewAccount.userInteractionEnabled = YES;
    
    //---UITextField Delegate perpose---//
    self.userName.delegate = self;
    self.password.delegate = self;
    self.userName.tag = 1;
    self.password.tag = 2;
    self.userNameSelectImgView.hidden = YES;
    self.passwordSelectImgView.hidden = YES;
    self.navigationController.navigationBar.barTintColor = RGB(1, 52, 112);
    //self.navigationController.navigationBarHidden = YES;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIDeviceOrientationPortrait]
                                forKey:@"orientation"];
    [self restrictRotation:YES];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568.0) {
        self.infoLabelTopConstraint.constant = 40;
        
    }else if ([[UIScreen mainScreen] bounds].size.height == 480.0) {
        self.infoLabelTopConstraint.constant = 20;
    }
    
}

-(void) restrictRotation:(BOOL)restriction
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.restrictRotation = restriction;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Local Methods

- (BOOL)checkInput {
    
    NSString *alertMessage = nil;
    if ([self.userName.text isEqualToString:@""] || [self.userName.text isEqual:nil]) {
        
        alertMessage = @"User name cannot be empty";
        
    }else if ([self.password.text isEqualToString:@""] || [self.password.text isEqual:nil]) {
        
        alertMessage = @"Password cannot be empty";
        
    }
    
    if (alertMessage == nil) {
        
        
        User *user = [User new];
        user.UserName = _userName.text;
        user.Password = _password.text;
        //---Common data filled-up by back-end for Consumer User---//
        return YES;
        
    }else {
        
        [self showAlertMessage:nil message:alertMessage];
        return NO;
        
    }
    
}

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message
{
    
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   //
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Button Action

- (IBAction)CancelAction:(id)sender {
    
    CGPoint translation = CGPointMake(0, -200);
    CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, 1, translation.x, translation.y);
    [UIView animateWithDuration:0.5 animations:^{
        self.infoView.transform = transform;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.infoView.hidden = YES;
        
    }];
}

- (IBAction)loginAction:(id)sender {
    //---Dismiss the keyboard.---//
    [self downNotification];
    [self.userName resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
    [self saveConf];
    //---Check for InputTextField is filled?---//    
}

- (void)saveConf {
    _surroundViewer.conf.userName = _userName.text;
    _surroundViewer.conf.password = _password.text;
    [_serviceOperator onOperate:SAVE_CONF andObject:_surroundViewer.conf];
    [_serviceOperator onOperate:LOAD_LOCAL];
}

- (void)createNewAccountTapped {
    NSLog(@"createAccount button Tapped.");
}
#pragma mark - TextField Delegate Methods -
//---dismiss keyboard when user tap other area outside textfield---//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    self.userNameSelectImgView.hidden = YES;
    self.passwordSelectImgView.hidden = YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        self.userNameSelectImgView.hidden = NO;
        self.passwordSelectImgView.hidden = YES;
        
    } else if (textField.tag ==2) {
        self.userNameSelectImgView.hidden = YES;
        self.passwordSelectImgView.hidden = NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    UITextField *tf = (UITextField *)textField;

    if ([[UIScreen mainScreen] bounds].size.height == 568.0) {
        
        self.offset2ViewMoveUp = 130.0;
        [self upNotification];
        
    }else if ([[UIScreen mainScreen] bounds].size.height == 480.0) {
        if (tf.tag == 1) {
            self.offset2ViewMoveUp = 60.0;
            
        }else {
            self.offset2ViewMoveUp = 120.0;
        }
        [self upNotification];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self downNotification];
    
}

#pragma mark - UIView Transition for UITextField -
- (void) upNotification {
    
    //NSLog(@"up notification");
    
    if (!self.isAlreadyUp) {
        self.isAlreadyUp = YES;
        [UIView animateWithDuration:0.1
                         animations:^ {
                             //NSLog(@"view center=%f",self.view.center.y);
                             
                             self.view.center = CGPointMake(self.view.center.x, self.view.center.y-self.offset2ViewMoveUp);
                         }
                         completion:^(BOOL finished){
                         }];
    }
    
}

- (void) downNotification {
    
    // NSLog(@"down notification");
    if (self.isAlreadyUp) {
        self.isAlreadyUp = NO;
        [UIView animateWithDuration:0.1
                         animations:^ {
                             //NSLog(@"view center=%f",self.view.center.y);
                             
                             self.view.center = CGPointMake(self.view.center.x, self.view.center.y+self.offset2ViewMoveUp);
                         }
                         completion:^(BOOL finished){
                         }];
    }
    
}

- (void)updateUI {
    
    _userName.text = _surroundViewer.conf.userName;
    _password.text = _surroundViewer.conf.password;
}

- (BOOL)isEmpty {
    NSLog(@"user %@ pass %@",_surroundViewer.conf.userName,_surroundViewer.conf.password);
    if(_surroundViewer.conf.userName.length == 0) {
        return YES;
    }else if (_surroundViewer.conf.password.length == 0){
        return YES;
    }else return NO;
    
}


@end
