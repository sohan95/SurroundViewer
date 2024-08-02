//
//  CameraStreamingViewController.m
//  CiscoOnvifPlayer
//
//  Created by einfochips on 21/10/14.
//  Copyright (c) 2014 einfochips. All rights reserved.
//

#import "StreamingVC.h"
#import "Constant.h"
#import "UINavigationController+AutorotationFromVisibleView.h"

#import "StreamerConfiguration.h"

#define ptzViewWidth    113
#define ptzViewHeight   147

#define ptzViewWidthiPad    155
#define ptzViewHeightiPad   194

@interface StreamingVC ()
{
	NSString *textMessage;
    
    BOOL isPlayerAlreadyStarted;
    __weak IBOutlet NSLayoutConstraint *heightMovieView;
    __weak IBOutlet NSLayoutConstraint *widthMovieView;
    
    StreamerConfiguration *streamerConfig;
}

@end

@implementation StreamingVC

@synthesize isONVIFPlayer, livePlaybackController, isDispalyInMultiPane, myTagValue, movieView, ptzControlsView, stateBeforeFullScreen;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self)
	{
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    streamerConfig = [StreamerConfiguration sharedInstance];
    cameraPTZSettingView = nil;
    isPlayerAlreadyStarted = NO;
    if (self.isDispalyInMultiPane) {
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    }
    [self initializePlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
	
	[self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	
    NSLog(@"myTagValue~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~::%d",self.myTagValue);
    [self startPlaying];
}

- (void)viewWillDisappear:(BOOL)animated
{
#if !TARGET_IPHONE_SIMULATOR
    if (!self.isDispalyInMultiPane) {
        [self.livePlaybackController manuallyStopPlayback];
        
        NSLog(@"viewWillDisappear::::::::: TAG:%d",self.myTagValue);
        [self stopPlayback];
    }
    
#endif
    
    [self.tabBarController.tabBar setHidden:NO];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [self.livePlaybackController screenDisappear];
    
	[super viewDidDisappear:animated];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
	// If any memory warning occur then stop streaming to prevent OS to kill application
	#if !TARGET_IPHONE_SIMULATOR
        [self stopPlayback];
	#endif
	
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"---------------------- streamer dealloc");
}

- (void)initializePlayer {
    
    btnRetryPlayback.hidden = true;
    textMessage = @"";
    
    mbProgressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    mbProgressHUD.backgroundColor = [UIColor darkGrayColor];
    [self.movieView addSubview:mbProgressHUD];
    mbProgressHUD.delegate = self;
    [mbProgressHUD hide:YES];
    
    self.livePlaybackController = [[LivePlaybackController alloc] init];
    self.livePlaybackController.delegate = self;
}

- (void)startPlaying {
    isPlayerAlreadyStarted = YES;
    // Start Streaming on When View Appeared
#if !TARGET_IPHONE_SIMULATOR
    [self startPlayback];
#endif
    
    // PTZ View should be visible only when playing for PTZ Camera with ONVIF support
    if (self.isONVIFPlayer && self.isCameraPTZCapable)
    {
        if (self.isDispalyInMultiPane) {
            [self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
        }
        
        [self setPTZView];
        
    }
}

// on Retry button Touched
// If Player fails to stream video, user can try again using retry button
- (IBAction)btnRetryTochued:(id)sender
{
	btnRetryPlayback.hidden = true;
	
#if !TARGET_IPHONE_SIMULATOR
	[self startPlayback];
#endif
}

#pragma mark - Internal

// Set PTZ View for PTZ enabled Camera
- (void)setPTZView
{
    if (cameraPTZSettingView == nil) {
        cameraPTZSettingView = [[CameraPTZSettingView alloc] initWithFrame:CGRectMake(0, 0, self.ptzControlsView.frame.size.width, self.ptzControlsView.frame.size.height)];
        [self.ptzControlsView addSubview:cameraPTZSettingView];
    }

    // Start
    [cameraPTZSettingView startPtzWithXaddrs:self.xAddr username:self.username password:self.password mediaProfileToken:self.ptzProfileToken];
    
    [self.ptzControlsView bringSubviewToFront:cameraPTZSettingView];
    
    // Disable all PTZ controls for PTZ Camera that does not have PTZ Profile configured with Media Profile
    if (self.isCameraPTZCapable && self.ptzProfileToken == nil)
    {
        self.ptzControlsView.userInteractionEnabled = NO;

        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"PTZ Settings of camera not configured properly"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self stopPlayback];
                                       [self.livePlaybackController closePlayback:nil];
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma -mark VLC Methods

// Remove Space and Escape Characters
-(NSString *) UrlEncodeString:(NSString *) str
{
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
	
    return [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Remote events

#if !TARGET_IPHONE_SIMULATOR

// Handle Remote events
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self.livePlaybackController play];
            break;
			
        case UIEventSubtypeRemoteControlPause:
            [self.livePlaybackController pause];
            break;
        default:
            break;
    }
}

#pragma mark - controls

- (void)manuallyStopPlayback {
    BOOL isPlayingWithOthers = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
    
    if (!isPlayingWithOthers) {
        NSLog(@"NOT anyother AUDIO playing.");
        [self.livePlaybackController manuallyStopPlayback];
        
        [self stopPlayback];
    }
    else
        NSLog(@"STILL some AUDIO playing.");
    
}

// Play/Pause Operation
- (BOOL)isVideoPlaying {
    return [self.livePlaybackController isPlaying];
}

- (void)pauseVideo {
    [self.livePlaybackController pause];
}

- (void)playVideo {
    [self.livePlaybackController play];
}

// Audio operations
- (BOOL)isAudioMuted {
    return [self.livePlaybackController isAudioMuted];
}

- (void)muteAudio {
    [self.livePlaybackController muteAudio];
}

- (void)unmuteAudio {
    [self.livePlaybackController unMuteAudio];
}

- (void)stopPlayback
{
    NSLog(@"stopPlayback ==========> TAG:%d",self.myTagValue);
    [self.livePlaybackController stopPlayback];
}

#pragma mark - Managing the media

- (void)startPlayback
{
	NSLog(@"startPlayback start ==========> TAG:%d",self.myTagValue);

    [self.livePlaybackController initializeMediaPlayer:self.movieView withURL:self.url forTag:self.myTagValue ipCameraRTSPURL:self.isONVIFPlayer];
    
	mbProgressHUD.detailsLabelText = textMessage;
	[mbProgressHUD show:YES];
	[self.view bringSubviewToFront:mbProgressHUD];
//	[self playNewMedia];
	NSLog(@"startPlayback end ==========>");
}

- (void)playNewMedia
{
    [self.livePlaybackController play];
}

#endif

#pragma -mark Orientations Change Methods

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

//
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    //The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toOrientation   = [[UIDevice currentDevice] orientation];
    //fixes orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if (toOrientation == UIInterfaceOrientationLandscapeRight) toOrientation = UIInterfaceOrientationLandscapeLeft;
    else if (toOrientation == UIInterfaceOrientationLandscapeLeft) toOrientation = UIInterfaceOrientationLandscapeRight;
    
    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self willRotateToInterfaceOrientation:toOrientation duration:0.0];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self willAnimateRotationToInterfaceOrientation:toOrientation duration:[context transitionDuration]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self didRotateFromInterfaceOrientation:fromOrientation];
    }];
}

- (void)setMediaAndPTZViewPortrait {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.movieView.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height-ptzViewHeightiPad-5);
        
        CGFloat xPos = self.view.frame.size.width/2 - ptzViewWidthiPad/2;
        self.ptzControlsView.frame = CGRectMake(xPos+10, self.movieView.frame.size.height + 3,ptzViewWidthiPad,ptzViewHeightiPad);
    }
    else {
        self.movieView.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height-ptzViewHeight-5);
        
        CGFloat xPos = self.view.frame.size.width/2 - ptzViewWidth/2;
        self.ptzControlsView.frame = CGRectMake(xPos, self.movieView.frame.size.height + 3,ptzViewWidthiPad,ptzViewHeight);

    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	 NSString *multiPaneStyle = [streamerConfig getSelectedLayoutStyle];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
			case UIDeviceOrientationPortraitUpsideDown:
                if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                    
                    self.ptzControlsView.hidden = NO;
                    
                    if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                        [self setMediaAndPTZViewPortrait];
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                        [self setMediaAndPTZViewPortrait];
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                        self.ptzControlsView.hidden = YES;
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                        [self setMediaAndPTZViewPortrait];
                    }
                }
                else {
                    
                    self.ptzControlsView.hidden = NO;
                    if (self.isDispalyInMultiPane) {
                        self.movieView.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
                    }
                    else {
                        //self.movieView.frame = CGRectMake(0,0,768,479);
                        self.movieView.frame = CGRectMake(0,44,768,479);
                    }
                }
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                
                if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                    self.ptzControlsView.hidden = NO;
                    
                    if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                        self.ptzControlsView.hidden = YES;
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {

                        [self setMediaAndPTZViewPortrait];
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                        
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width-ptzViewWidthiPad-5,self.view.frame.size.height);
                        
                        CGFloat yPos = self.view.frame.size.height/2 - ptzViewHeightiPad/2;
                        self.ptzControlsView.frame = CGRectMake(self.movieView.frame.size.width + 3,yPos,ptzViewWidthiPad,ptzViewHeightiPad);
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                        self.ptzControlsView.hidden = YES;
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                }
                else
                {
                    self.ptzControlsView.hidden = YES;
                    self.movieView.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
                }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (interfaceOrientation)
        {
            case UIInterfaceOrientationPortrait:
			case UIInterfaceOrientationPortraitUpsideDown:
            {
                if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                    
                    self.ptzControlsView.hidden = NO;
                    
                    if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                        [self setMediaAndPTZViewPortrait];

                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                        [self setMediaAndPTZViewPortrait];

                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                        self.ptzControlsView.hidden = YES;
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                        [self setMediaAndPTZViewPortrait];
                    }
                }
                else {
                    self.ptzControlsView.hidden = NO;
                    
                    if (self.isDispalyInMultiPane) {
                         self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                    else {
                        self.movieView.frame = CGRectMake(0,44, self.view.frame.size.width,self.view.frame.size.height-44);
                    }
                }
            }
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
			case UIInterfaceOrientationLandscapeRight:
                
                if (self.isDispalyInMultiPane && self.isCameraPTZCapable) {
                    self.ptzControlsView.hidden = NO;
                    
                    if ([multiPaneStyle isEqualToString:kLayoutStyle1x1]) {
                        self.ptzControlsView.hidden = YES;
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle1x2]) {
                       [self setMediaAndPTZViewPortrait];
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x1]) {
                        
                        CGFloat xpos = self.view.frame.size.width - ptzViewWidth-50;
                        
                        self.movieView.frame = CGRectMake(0,0, xpos,self.view.frame.size.height);
                        self.ptzControlsView.frame = CGRectMake(self.movieView.frame.origin.x +self.movieView.frame.size.width + 5,self.movieView.frame.origin.y-10,ptzViewWidth,ptzViewHeight);
                        
                    }
                    else if ([multiPaneStyle isEqualToString:kLayoutStyle2x2]) {
                        self.ptzControlsView.hidden = YES;
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
                    }
                }
                else
                {
                    self.ptzControlsView.hidden = YES;
                    
                    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)
                    {
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);//,320);
                    }
                    else
                    {
                        self.movieView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);//,320);
                    }
                }
                
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - LivePlaybackController Delegate Methods

- (void)notifyOnError:(NSString *)status {
    if ([status isEqualToString:kNetworkNotAvailable]) {
        
        [mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
        
        // Network not reachable
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:kNetworkNotAvailable
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.navigationController popViewControllerAnimated:YES];
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([status isEqualToString:kProblenWhileLoadingVideo]) {
        
        btnRetryPlayback.hidden = true;
        textMessage = @"Problem while loading Video, trying to reconnect";
        mbProgressHUD.detailsLabelText = textMessage;
        [mbProgressHUD show:YES];
    }
}

- (void)notifyStatusUpdate:(NSString *)status forPositionView:(NSUInteger)position {
    
//    NSLog(@"notifyStatusUpdate PRJ  +=+=+=+=+=+=+=+=+=+=+=+=+=+=+= status:%@",status);

    if ([status isEqualToString:kStartPlayback] || [status isEqualToString:kAppEnterInForeground]) {
        textMessage = @"";
        [self startPlayback];
    }
    else if ([status isEqualToString:kStopPlayback]) {
        [self stopPlayback];
    }
    else if ([status isEqualToString:kClosePlayback]) {
        [mbProgressHUD hide:YES];
        [self.view bringSubviewToFront:self.movieView];
    }
    else if ([status isEqualToString:kAppRunningInBackground]) {
        [self.movieView bringSubviewToFront:btnRetryPlayback];
    }
    else if ([status isEqualToString:kStartPlaying]) {
        [mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
//        NSLog(@"Change Frame in kStartPlaying ++++++++++++++++++++");
//        [self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    }
    else if ([status isEqualToString:kStartBuffering]) {
        [mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
//        NSLog(@"Change Frame in kStartBuffering ********************");
//        [self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    }
    else if ([status isEqualToString:kPlayerIsReady]) {
        [mbProgressHUD hide:YES];
        [self.view sendSubviewToBack:mbProgressHUD];
        
        [self playNewMedia];
    }
}

@end
