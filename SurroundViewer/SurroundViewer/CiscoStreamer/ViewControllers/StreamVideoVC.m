//
//  StreamVideoVC.m
//  VideoStreamer
//
//  Created by AHMLPT0406 on 10/02/15.
//  Copyright (c) 2015 AHMLPT0406. All rights reserved.
//

#import "StreamVideoVC.h"
//#import "CaptureVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UINavigationController+AutorotationFromVisibleView.h"
#import "AlertView.h"

#import "Constant.h"
#import "NSDataAdditions.h"
#import "XMLDictionary.h"
#import "StreamerConfiguration.h"
#import "Base64.h"

#import "AppDelegate.h"
#import "SettingsTableViewController.h"

@interface StreamVideoVC ()
{
    BOOL isStartRecording;
    
    LiveStreamController *liveStreamController;
    StreamerConfiguration *streamerConfig;
    
    UIAlertView *alert;
    UIAlertController *alertVC;
    
    NSString *currentResolution, *currentFrameRate, *currentBitRate, *currentStreamType;
    BOOL isSettingChanged, isDisplayProssingForStop;//, isStartPorcessing;
}

@property (nonatomic, retain) MBProgressHUD *mBProgressHUD;

@property (retain, nonatomic) LiveStreamController *liveStreamController;
@property (assign, nonatomic) BOOL isStartRecording;

@end

@implementation StreamVideoVC

//isNetworkAvilable
@synthesize isStartRecording;
@synthesize liveStreamController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Video Streamer";
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    
    isDisplayProssingForStop = NO;
    isSettingChanged = NO;
    currentResolution = [streamerConfig getResolution];
    currentFrameRate = [streamerConfig getFrameRate];
    currentBitRate = [streamerConfig getSelectedBitRate];
    currentStreamType = [streamerConfig getStreamType];
    
    //set connection delegate
    //Start Capturing video
    self.liveStreamController = [[LiveStreamController alloc] init];
    self.liveStreamController.delegate = self;
    
    //Setting Progressbar
    self.mBProgressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.mBProgressHUD];
    self.mBProgressHUD.delegate = self;
    
    if([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient])
    {
        self.title = @"Video Streamer Client";
//        self.mBProgressHUD.labelText = @"Connecting To Server...";
//        [self.mBProgressHUD show:YES];
    }
    else
    {
        self.rtspServerUrlLabel.text = @"Server URL";
        self.title = @"Video Streamer Server";
//        self.mBProgressHUD.labelText = @"Initiating To Server...";
//        [self.mBProgressHUD show:YES];
    }
    
    [self notifyStatusUpdate:kStartDisplayingProcessing];
    
    [self.startStopRecordingView setHidden:YES];
    self.startStopRecordingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Start Capturing video
    //[self.liveStreamController startStreaming];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.liveStreamController screenAppear];
    
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isSettingChanged ) { //&& !isStartPorcessing) {
        //isSettingChanged = NO;
        
        if ([self isRequireToRestartStreaming]) {
            //Resolution has been changed by user, need to Restart
            
//            isStartPorcessing = YES;
            currentResolution = [streamerConfig getResolution];
            
            //            [self.liveStreamController performSelectorInBackground:@selector(stopStreaming) withObject:nil];
            
            isDisplayProssingForStop = YES;
            [self notifyStatusUpdate:kStartDisplayingProcessing];
            [self.liveStreamController stopStreaming];
        }
        else
            isSettingChanged = NO;
    } else {
        //Start Capturing video
        [self.liveStreamController startStreaming];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //remove notification
    
    if (!isSettingChanged) {
        [self.liveStreamController stopStreaming];
    }
    
    [self.liveStreamController screenDisapper];
    
    self.navigationController.navigationBarHidden = NO;
    [self.tabBarController.tabBar setHidden:NO];
    [super viewWillDisappear:YES];
}

- (void)updateCurrentSettings {
    NSLog(@"Reset updateCurrentSettings");
    
    currentResolution = [streamerConfig getResolution];
    currentFrameRate = [streamerConfig getFrameRate];
    currentBitRate = [streamerConfig getSelectedBitRate];
    currentStreamType = [streamerConfig getStreamType];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kChangedWowzaSettings];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isRequireToRestartStreaming {
    if (![[streamerConfig getResolution] isEqualToString:currentResolution] ||
        ![[streamerConfig getFrameRate] isEqualToString:currentFrameRate] ||
        ![[streamerConfig getSelectedBitRate] isEqualToString:currentBitRate] ||
        ![[streamerConfig getStreamType] isEqualToString:currentStreamType]) {
        
        return YES;
    }
    else {
        NSNumber *isWowzaSettingChanged = [[NSUserDefaults standardUserDefaults] valueForKey:kChangedWowzaSettings];
        if (isWowzaSettingChanged != nil && [isWowzaSettingChanged boolValue] == YES) {
            return YES;
        }
    }
    
    return NO;
}

#pragma -mark --Orientation Delegate Methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateRotationToInterfaceOrientation toInterfaceOrientation:%d",toInterfaceOrientation);
    AVCaptureVideoPreviewLayer* preview = [self.liveStreamController getPreviewLayerToBound:self.cameraView.bounds];
    [self.cameraView.layer addSublayer:preview];
//    [self.liveStreamController updateVideoPreviewWithBound:self.cameraView.bounds];
}

#pragma -mark --Internal Methods

- (void)startVideoDisplay
{
    //Start captureing video and set view layer for user visibility
    AVCaptureVideoPreviewLayer* preview = [self.liveStreamController getPreviewLayerToBound:self.cameraView.bounds];
    [self.cameraView.layer addSublayer:preview];
    
//    if([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient])
//    {
//        [self notifyStatusUpdate:kConnectionStateConnecting];
//    }
}

#pragma -mark --IBAction Methods

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            break;
    }
    return AVCaptureVideoOrientationPortrait;
}

#pragma -mark --Orientations Change Methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
   
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        AVCaptureVideoPreviewLayer* preview = [self.liveStreamController getPreviewLayerToBound:self.cameraView.bounds];
        [self.cameraView.layer addSublayer:preview];
//        [self.liveStreamController updateVideoPreviewWithBound:self.cameraView.bounds];
        
        [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
    }];
    
}

- (void)updateLabelWithStatusMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamingStatusLabel setText:message];
        [self.streamingStatusLabel setHidden:NO];
    });
}



#pragma -mark --AlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma -mark --Button Actions

- (IBAction)switchCameraTapped:(id)sender
{
    [self.liveStreamController switchCamera];
}

- (IBAction)tappedStartStopRecording:(id)sender {
    self.isStartRecording = [sender isOn];
    NSLog(@"tappedStartStopStreaming------> %d",self.isStartRecording);
    
    if (self.isStartRecording) {
        //Start Streaming
        [self notifyStatusUpdate:kStartRecording];
    } else {
        [self notifyStatusUpdate:kStopRecording];
    }
}

- (IBAction)tappedStopStreaming:(id)sender {
    
    //[self.liveStreamController stopStreaming];
    
    [self showOptionsOnStopStreaming:sender];
}

- (IBAction)tappedSettings:(id)sender {
    
    isSettingChanged = YES;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    settingsVC.screenTag = 100;
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)startRecording {
    
    NSLog(@"in startRecording");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.startStopRecordingView setHidden:NO];

        self.sizeLabel.text = @"";
        [self.startStopRecordingSwitch setOn:YES];
//        [self.startStopRecordingButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    });
}

- (void)stopRecording {
    
    NSLog(@"in stopRecording");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.startStopRecordingSwitch setOn:NO];
//        [self.startStopRecordingButton setTitle:@"Start Recording" forState:UIControlStateNormal];
        
        NSLog(@"In if for hide Recording view");
        [self.startStopRecordingView setHidden:YES];
    });
}

- (void)updateStartStopStreamingButtonTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.startStopStreamingButton setTitle:title forState:UIControlStateNormal];
    });
}

- (void)closeStreamingVCAndLoadInstantClient {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        [delegate openReturnToInstantConnect];
    });
}

- (void)showAlertPopup:(NSString *)message {
    
    alertVC =   [UIAlertController
                 alertControllerWithTitle:@"Error Connection Failed"
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOk = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alertVC dismissViewControllerAnimated:YES completion:nil];
                                
                                [self closeStreamingVCAndLoadInstantClient];
                                
//                                [self.navigationController popViewControllerAnimated:YES];
                            }];
    
    [alertVC addAction:btnOk];
    [self presentViewController:alertVC animated:YES completion:nil];
    
    [self.mBProgressHUD hide:YES];
}

- (void )showOptionsOnStopStreaming:(id)sender {
    
    UIButton *clickedButton = (UIButton *) sender;
    
    alertVC =   [UIAlertController
                                  alertControllerWithTitle:@"Video Connect Plugin"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* returnToInstanceConnect = [UIAlertAction actionWithTitle:@"Return to Instant Connect" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Load Instance Connect
                                                       [self closeStreamingVCAndLoadInstantClient];
                                                   }];
    
    UIAlertAction* restartStreaming = [UIAlertAction actionWithTitle:@"Restart Streaming" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       isSettingChanged = YES;
                                                       [self.liveStreamController stopStreaming];
//                                                       [self.liveStreamController startStreaming];
                                                       
                                                   }];
    
    [alertVC addAction:returnToInstanceConnect];
    [alertVC addAction:restartStreaming];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alertVC dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alertVC addAction:cancel];
    }
    
    
//    [alertVC addAction:cancel];
    
    [alertVC setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
    popPresenter.sourceView = clickedButton;
    popPresenter.sourceRect = clickedButton.bounds;
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - LiveStreamControllerDelegate Methods

- (void)updateAvailableSizeLabel:(NSString *)sizeInStr {
    
    NSLog(@"sizeInStr:%@",sizeInStr);
    self.sizeLabel.text = sizeInStr;
}

- (void)setRTSPURL:(NSString *)rtspURL {
    [self.rtspServerUrlLabel setHidden:NO];
    self.rtspServerUrlLabel.text = rtspURL;
}

- (void)notifyOnError:(NSString *)status {
    NSString *alertMessage = @"";
    
    if ([status isEqualToString:kConnectionErrorMessageRTSPSink]) {
        alertMessage = status;
        
    } else if ([status isEqualToString:kConnectionErrorMessageRequestFail]) {
        alertMessage = @"Wowza server unreachable\nPlease check wowza setting or netwrok connectivity";
        
    } else if ([status isEqualToString:kConnectionErrorMessageStreamPlay]) {
        alertMessage = status;
        
    } else if ([status isEqualToString:kConnectionErrorMessageTimeOut]) {
        alertMessage = status;
    }
    else if ([status isEqualToString:kAuthenticationFailed]) {
        alertMessage = @"Please Enter Valid Ipaddress, Username, Password and Port.";
    }
    else if ([status isEqualToString:kNetworkNotAvailable]) {
        alertMessage = @"Internet Connection Is Not Avilable";
    }
    
//    isStartPorcessing = NO;
    
    [self showAlertPopup:alertMessage];
    [self.liveStreamController stopVideoRecording];
}

- (void)notifyStatusUpdate:(NSString *)status
{
    NSLog(@"in STREAMER PRJ notifyStatusUpdate:%@",status);
    
    if ([status isEqualToString:kStartDisplayingProcessing]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (isDisplayProssingForStop) {
                self.mBProgressHUD.labelText = @"Stopping Server...";
//                isDisplayProssingForStop = NO;
            }
            else {
                if([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient])
                {
                    self.mBProgressHUD.labelText = @"Connecting To Server...";
                }
                else
                {
                    self.mBProgressHUD.labelText = @"Initiating To Server...";
                }
            }
            
            [self.mBProgressHUD show:YES];
        });
        
        [self notifyStatusUpdate:kConnectionStateConnecting];
    }
    else if ([status isEqualToString:kStartStreaming]) {
        if ([alert isVisible]|| [alertVC isViewLoaded])
        {
            [alert dismissWithClickedButtonIndex:1 animated:YES];
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient])
//            {
//                self.mBProgressHUD.labelText = @"Connecting To Server...";
//            }
//            else
//            {
//                self.mBProgressHUD.labelText = @"Initiating To Server...";
//            }
        
//            [self.mBProgressHUD show:YES];
//        });
        
        
        
        [self startVideoDisplay];
        
//        [self notifyStatusUpdate:kStartDisplayingProcessing];
//        isSettingChanged = NO;
//        [self.mBProgressHUD hide:YES];
//        [self updateLabelWithStatusMessage:kConnectionStateStreaming];
    }
    else if ([status isEqualToString:kStopStreaming]) {
        
        //[self.liveStreamController stopVideoRecording];
        
        NSLog(@"Stop Video Stream and Encoding");
        
        if (!isSettingChanged) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            
            NSLog(@"Successfully Stoped client streaming. Now Again Restart.");
            [self notifyStatusUpdate:kStartDisplayingProcessing];
            [self.liveStreamController performSelector:@selector(startStreaming) withObject:nil afterDelay:2.0];
//            [self.liveStreamController performSelectorInBackground:@selector(startStreaming) withObject:nil];
//            [self.liveStreamController startStreaming];
//            isSettingChanged = NO;
        }
    }
    else if ([status isEqualToString:kStartRecording]) {
        [self.liveStreamController startVideoRecording];
        
        [self startRecording];
    }
    else if ([status isEqualToString:kStopRecording]) {
        [self.liveStreamController stopVideoRecording];
        
        [self stopRecording];
    }
    else if ([status isEqualToString:kConnectionStateConnecting]) {
        if (isDisplayProssingForStop) {
            [self updateLabelWithStatusMessage:@"Stopping..."];
            isDisplayProssingForStop = NO;
        }
        else {
            
            if ([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient]) {
                [self updateLabelWithStatusMessage:[NSString stringWithFormat:@"%@...",kConnectionStateConnecting]];
            }
            else {
                [self updateLabelWithStatusMessage:[NSString stringWithFormat:@"%@...",kConnectionStateInitiating]];
            }
        }
        
    } else if ([status isEqualToString:kConnectionStateConnected]) {
        
        [self updateCurrentSettings];
        NSLog(@"Streaming Started, So set isSettingChanged ==== NO");
        //isStartPorcessing =
        isSettingChanged = NO;
        [self.mBProgressHUD hide:YES];
        [self updateLabelWithStatusMessage:kConnectionStateStreaming];
        
        [self updateStartStopStreamingButtonTitle:@"Stop Streaming"];
    }
    else if ([status isEqualToString:kConnectionStateDisconnected]) {
        [self updateLabelWithStatusMessage:kConnectionStateDisconnected];
        [self updateStartStopStreamingButtonTitle:@"Stop"];

        //[self notifyStatusUpdate:kStartDisplayingProcessing];
        
//        if([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient])
//        {
//            self.mBProgressHUD.labelText = @"Connecting To Server...";
//        }
//        else
//        {
//            self.mBProgressHUD.labelText = @"Initiating To Server...";
//        }
//        
//        [self.mBProgressHUD show:YES];
    }
}

@end
