//
//  firstViewController.m
//  cisco_demo
//
//  Created by einfochips on 2/23/16.
//  Copyright © 2016 einfochips. All rights reserved.
//

#import "MultiPaneViewController.h"
#import "StreamerConfiguration.h"
#import "Constant.h"

#import "StreamingVC.h"
#import "IPCameraViewerVC.h"

#import "IPCameraController.h"
#import "MBProgressHUD.h"

#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>
//---sohan//
#import "JsonUtil.h"
#import "PopUpSubViewController.h"
#import "SurroundViewer.h"
#import "ReplyHandler.h"
#import "SurroundServiceWrapper.h"
#import "TableUpdater.h"
#import "SurroundOperate.h"
#import "ReplyHandler.h"
#import "CustomTableViewCell.h"
#import "SurroundDefine.h"
#import "LogInViewController.h"
//sohan---|

#define margin 5

#define kInnerContainerViewTag  1000
#define kPaneViewTag            2000
#define kPaneButtonTag          3000
//#define kPaneTitleTag           4000
#define kPaneControlsTag        5000

#define kMuteUnmuteButtonTag    6000
#define kPausePlayButtonTag     7000
#define kChangeViewButtonTag    8000
#define kStartRecordButtonTag   9000

#define kWebViewTag             10000
#define kPaneTitleContainerTag   4000
#define kPaneTitleTag            4100
#define kPaneTitleNameTag        4200
#define kPaneTitleTimeTag        4300

@interface MultiPaneViewController () <UITextFieldDelegate, UIWebViewDelegate, AVPlayerViewControllerDelegate, MBProgressHUDDelegate, IPCameraControllerDelegate, UIGestureRecognizerDelegate, Progress, Updater,LoginUpdater>
{
	int n ,m;
    int fullScreenTagValue;
	NSMutableArray *Views1;
    NSString *currentPaneType;
    
    NSUInteger ipCameraViewTag, ipCameraArrIndex;
    
    StreamerConfiguration *streamerConfig;
    IPCameraViewerVC *ipCameraViewerObj;
    
    MBProgressHUD *mbProgressHUD;
//    MBProgressHUD *mbProgressHUDInitial;
    
    IPCameraController *ipCameraController;
    
    NSString *ptzProfileTokenVal;
    NSString *selectedIPCameraAddress;
    NSMutableDictionary *streamerVCObjects;
    
    NSMutableDictionary *coordinateDictionary;
     NSMutableDictionary *coordinateDictionary2;
    NSMutableArray *tagFullScreen;
    
    NSMutableArray *surveillanceIPCameras;
    NSMutableArray *userCameras;
    //sohan
    PopUpSubViewController *popUpSubViewController;
    SurroundViewer *_surroundViewer;
    ReplyHandler *_handler;
    id<Operator> _operator;
    SurroundServiceWrapper *_service;
    LogInViewController *_loginVC;
    MBProgressHUD *_hud;
    UIAlertController *_alertController;
    UIAlertAction *_okAction;
//    NSMutableArray *_cameraQueue;
    NSMutableArray *_players;
}

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, retain)  UITextField *webUrl;
@property (nonatomic, retain)  UITextField *tvFeed;

@property (nonatomic, retain) IPCameraController *ipCameraController;
@property (nonatomic, retain) MBProgressHUD *mbProgressHUD;
//---sohan---//
@property (nonatomic, assign) NSInteger selectedPanelTag;
@property(nonatomic, assign) BOOL isMultiPanelVCLoadAble;
@property(nonatomic, assign) BOOL fromlogin;
@property(nonatomic, assign) BOOL isDefaultVideoLoaded;
@end

@implementation MultiPaneViewController

@synthesize containerView, ipCameraController, mbProgressHUD;

- (void)loadView {
    [super loadView];
    _service = [[SurroundServiceWrapper alloc] initWithReplyHandler:nil];
    _operator = _service;
    _surroundViewer = [[SurroundViewer alloc] init];
    _handler = [[ReplyHandler alloc] initWithSurroundViewer:_surroundViewer operator:_operator progress:self loginUpdate:self cameraUpdater:nil friendsCamUpdater:nil channelsUpdater:nil andTarget:self];
    
    _service.replyHandler = _handler;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
    //to hold player
    _players = [[NSMutableArray alloc] initWithCapacity:4];
    for(int i = 0; i < 4; i++) [_players addObject:@""];
    
    fullScreenTagValue = -1;
    ipCameraViewerObj = nil;
    _webUrl = nil;
    streamerVCObjects = [NSMutableDictionary dictionaryWithCapacity:0];
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    [self.containerView setBackgroundColor:[UIColor grayColor]];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [self.containerView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTapVisibleConrols = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSingleTap:)];
    singleTapVisibleConrols.delegate = self;
    singleTapVisibleConrols.numberOfTapsRequired = 1;
    [self.containerView addGestureRecognizer:singleTapVisibleConrols];
    
    [singleTapVisibleConrols requireGestureRecognizerToFail:doubleTap];
    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    audioSession setCategory:<#(nonnull NSString *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>
    
    //---sohan---//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePopUpSubViewNotification:)
                                                 name:@"PopUpSubViewNotification"
                                               object:nil];
    
    self.navigationItem.hidesBackButton = YES;
    if (!_loginVC) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        _loginVC = (LogInViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
        _loginVC.serviceOperator = _operator;
        _loginVC.surroundViewer = _surroundViewer;
    }
    _okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [_operator onOperate:LOAD_LOCAL];
    [_loginVC updateUI];
    
    //--Initialized 2x2 paneView each time when viewDidLoad Called---//
    self.isDefaultVideoLoaded = NO;
    [streamerConfig setSelectedLayoutStyle:kLayoutStyle2x2];
    currentPaneType = [streamerConfig getSelectedLayoutStyle];
    [self addMultiPaneControls];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_fromlogin) return;
    [self restrictRotation:NO];
    
    //--set title of MultiPanelVC
    self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"   Watch Me ! %@",[streamerConfig getSelectedLayoutStyle]];
    
    if (_isDefaultVideoLoaded) {
        
        NSString *previousPaneType = currentPaneType;
        if (previousPaneType == nil) {
            previousPaneType = kLayoutStyle2x2;
        }
        currentPaneType = [streamerConfig getSelectedLayoutStyle];
        
        if (![previousPaneType isEqualToString:currentPaneType] || [[self.containerView subviews] count] <= 0) {
            [self addMultiPaneControlsTwo];
            [self performSelector:@selector(playBackMethods) withObject:nil afterDelay:0.5];
        }
        else {
            
            for (NSString *tagIndex in [streamerVCObjects allKeys]) {
                StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
                if ([streamerVC.stateBeforeFullScreen isEqualToString:kVideoStatePause]) {
                    streamerVC.stateBeforeFullScreen = kVideoStatePlay;
                    [streamerVC playVideo];
                }
            }
        }
        
        NSUInteger toOrientation   = [[UIDevice currentDevice] orientation];
        [self dimensionAfterOrientationChange:toOrientation];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
        if ([streamerVC isVideoPlaying]) {
            streamerVC.stateBeforeFullScreen = kVideoStatePause;
            [streamerVC pauseVideo];
        }
    }
}

- (void)didReceiveMemoryWarning {
	
	[super didReceiveMemoryWarning];
	
}

- (BOOL)prefersStatusBarHidden {
	
	return YES;
}

#pragma mark - Restriction Rotation
-(void) restrictRotation:(BOOL)restriction
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.restrictRotation = restriction;
}

#pragma mark - Gesture recognizer delegate
//UITapGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    NSLog(@"gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer");
    return YES;
}

#pragma mark - Show/Hide PopUpSubView
- (void) removeIPCameraViewer {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [ipCameraViewerObj.view removeFromSuperview];
}

- (void) receivePopUpSubViewNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"PopUpSubViewNotification"]) {
        NSDictionary *dic = (NSDictionary *)notification.userInfo;
        UserPackage *userPackage = _surroundViewer.userPackages[0];
        [popUpSubViewController.view removeFromSuperview];
        
        if ([[dic objectForKey:@"videoType"] integerValue] == 0) {
            NSInteger selectedSection = [[dic objectForKey:@"selectedSection"] integerValue];
            NSInteger selectedRow = [[dic objectForKey:@"selectedRow"] integerValue];
            ChanelCategory *channelCategory = [userPackage.tvCCategoryList objectAtIndex:selectedSection];
            Channel *channel = [channelCategory.channels objectAtIndex:selectedRow];
            //[_players replaceObjectAtIndex:(self.selectedPanelTag-1)- kPaneButtonTag withObject:channel];
            [self loadRTSPStreamerForChannel:channel forTag:self.selectedPanelTag - kPaneButtonTag];
            
        }else if ([[dic objectForKey:@"videoType"] integerValue] == 1) {
            NSInteger selectedRow = [[dic objectForKey:@"selectedRow"] integerValue];
//            [self loadIPCameraView:self.selectedPanelTag - kPaneButtonTag forRowIndex:selectedRow];
            //
            Camera *ipCamera = [userPackage.userCameraList objectAtIndex:selectedRow];
            ipCamera.panelTag = [NSNumber numberWithInteger:self.selectedPanelTag - kPaneButtonTag];
//            [_cameraQueue addObject:ipCamera];
            //[self sendIPCameraProbeRequest:ipCamera forTag:self.selectedPanelTag - kPaneButtonTag];
            [self.navigationItem.rightBarButtonItem setEnabled:NO]; // Disables the button
            [self loadIPCameraView:self.selectedPanelTag - kPaneButtonTag forRowIndex:selectedRow];
            
        }else if ([[dic objectForKey:@"videoType"] integerValue] == 2) {
            NSInteger selectedRow = [[dic objectForKey:@"selectedRow"] integerValue];
            if (_webUrl == nil) {
                _webUrl = [[UITextField  alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            }
            FriendsCamera *fCamera = [_surroundViewer.friendsCameras.rows objectAtIndex:selectedRow];
            NSString *rtspURL = (NSString* )fCamera.cameraUrl;
            [_webUrl setText:rtspURL];
            
            [self loadRTSPStreamer:self.selectedPanelTag - kPaneButtonTag forArrIndex:selectedRow];
            
        }else if ([[dic objectForKey:@"videoType"] integerValue] == 3) {
            [self enterWebURL:self.selectedPanelTag forAction:@"play_web_url"];
            
        }else {
            //NSLog(@"Hide PopUpView");
        }
    }
}

- (void)showOptions:(id)sender {
    
    UIButton *clickedButton = (UIButton *) sender;
    self.selectedPanelTag = clickedButton.tag;
    
    int lastDigit = clickedButton.tag % 10;
    id player = [_players objectAtIndex:lastDigit-1];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    popUpSubViewController = (PopUpSubViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PopUpSubViewController"];
    popUpSubViewController.surroundViewer = _surroundViewer;
    
    if ([player isKindOfClass:[Channel class]]) {
        popUpSubViewController.selectedVideoType = 0;
    }else if ([player isKindOfClass:[Camera class]]) {
        popUpSubViewController.selectedVideoType = 1;
    }else if ([player isKindOfClass:[FriendsCamera class]]) {
        popUpSubViewController.selectedVideoType = 2;
    }else if ([player isKindOfClass:[UITextField class]]) {
        popUpSubViewController.selectedVideoType = 3;
    }else {
        popUpSubViewController.selectedVideoType = 3;
    }
    [self.navigationController.view addSubview:popUpSubViewController.view];
}

#pragma mark - Load Multi Panes

- (void)addMultiPaneControls {
    int	tagValue= 1;
    NSLog(@"Total VCObjects=%lu", (unsigned long)[streamerVCObjects count]);
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
        [streamerVC pauseVideo];
    }
    
    [NSThread sleepForTimeInterval:0.2];
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
        [streamerVC manuallyStopPlayback];
    }
    
    streamerVCObjects = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for ( UIView * innerContainer in [self.containerView subviews]) {
        
        for ( UIView *innerPaneView in innerContainer.subviews) {
            
            [innerPaneView removeFromSuperview];
        }
        
        [innerContainer removeFromSuperview];
    }
    
    fullScreenTagValue = -1;
    Views1 = [NSMutableArray arrayWithCapacity:0];          //------Array of views-----
    coordinateDictionary = [[NSMutableDictionary alloc]init];
    tagFullScreen = [[NSMutableArray alloc]init];
    
    NSArray *items = [currentPaneType componentsSeparatedByString:@"x"];
    n = [[items objectAtIndex:0]intValue];
    m = [[items objectAtIndex:1]intValue];
    
    for ( int i=0; i< n; i++)
    {
        for ( int j=0; j< m; j++)
        {
            
            CGRect p = [self PaneView:i rows:n cols:m  colval:j];
            UIView  *innerContainer = [[UIView alloc] initWithFrame:p];
            innerContainer.autoresizesSubviews = YES;
            [self.containerView addSubview:innerContainer];
            
            NSDictionary *dict = @{@"view":innerContainer,@"screen_type":@"small"};
            [Views1 addObject:dict];
            
            //---set PanelViewTitle---//
            UIView *viewTitleContainer = [[UIView alloc]
                        initWithFrame:CGRectMake(0,
                                                innerContainer.frame.size.height-30.0,
                                                 innerContainer.frame.size.width, 30.0)];
            viewTitleContainer.backgroundColor = RGB(48, 48, 50);
            viewTitleContainer.autoresizesSubviews = YES;
            viewTitleContainer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            UILabel *viewTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100, 30.0)];
            [viewTitle setFont:[UIFont systemFontOfSize:12]];
            [viewTitle setBackgroundColor: [UIColor clearColor]];
            [viewTitle setTextColor:[UIColor whiteColor]];
            
            
            UILabel *viewTitleName = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 120, 30.0)];
            [viewTitleName setFont:[UIFont systemFontOfSize:12]];
            [viewTitleName setBackgroundColor: [UIColor clearColor]];
            [viewTitleName setTextColor:[UIColor lightGrayColor]];
            viewTitleName.hidden = YES;
            
            UILabel *viewTitleTime = [[UILabel alloc] initWithFrame:CGRectMake(innerContainer.frame.size.width-60,0,80, 30.0)];
            [viewTitleTime setFont:[UIFont systemFontOfSize:10]];
            [viewTitleTime setBackgroundColor: [UIColor clearColor]];
            [viewTitleTime setTextColor:[UIColor lightGrayColor]];
            
            
            viewTitleContainer.tag = kPaneTitleContainerTag+ tagValue;
            viewTitle.tag = kPaneTitleTag + tagValue;
            viewTitleName.tag = kPaneTitleNameTag+ tagValue;
            viewTitleTime.tag = kPaneTitleTimeTag+ tagValue;
            
            [viewTitleContainer addSubview:viewTitle];
            [viewTitleContainer addSubview:viewTitleName];
            [viewTitleContainer addSubview:viewTitleTime];
            //---End PanelViewTitle---//
            
            UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            optionButton.frame = CGRectMake(innerContainer.frame.size.width - 44 - 5, 0.0, 44.0, 44.0);
            [optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [optionButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            optionButton.backgroundColor = [UIColor clearColor];
            optionButton.layer.cornerRadius = 10;
            optionButton.clipsToBounds = true;
            
            UIView *controlsView = [[UIView alloc] initWithFrame:CGRectMake(5, innerContainer.frame.size.height - 55, innerContainer.frame.size.width - 10, 50)];
            controlsView.backgroundColor = [UIColor lightGrayColor];
            [controlsView setHidden:YES];
            
            // Mute-Unmute Button
            UIButton *muteUnmuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            muteUnmuteButton.frame = CGRectMake(controlsView.frame.size.width/2 - (44 + 5), 3.0, 44.0, 44.0);
            [muteUnmuteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [muteUnmuteButton addTarget:self action:@selector(muteUnmutePlayer:) forControlEvents:UIControlEventTouchUpInside];
            [muteUnmuteButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
            muteUnmuteButton.backgroundColor = [UIColor clearColor];
            muteUnmuteButton.layer.cornerRadius = 10;
            muteUnmuteButton.clipsToBounds = true;
            muteUnmuteButton.tag = kMuteUnmuteButtonTag + tagValue;
            
            // Play-Pause Button
            UIButton *pausePlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
            pausePlayButton.frame = CGRectMake(muteUnmuteButton.frame.origin.x + muteUnmuteButton.frame.size.width + 5, 3.0, 44.0, 44.0);
            [pausePlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [pausePlayButton addTarget:self action:@selector(pausePlayVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
            [pausePlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            pausePlayButton.backgroundColor = [UIColor clearColor];
            pausePlayButton.layer.cornerRadius = 10;
            pausePlayButton.clipsToBounds = true;
            pausePlayButton.tag = kPausePlayButtonTag + tagValue;
            
            [controlsView addSubview:muteUnmuteButton];
            [controlsView addSubview:pausePlayButton];
            
            UIView *innerPaneView = [[UIView alloc] init];
            innerPaneView.autoresizesSubviews = YES;
            innerPaneView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            innerPaneView.frame = CGRectMake(0, 0, innerContainer.frame.size.width, innerContainer.frame.size.height);
            innerPaneView.backgroundColor  =[UIColor darkGrayColor];
            
            innerContainer.tag = kInnerContainerViewTag + tagValue;
            innerPaneView.tag = kPaneViewTag + tagValue;
            optionButton.tag = kPaneButtonTag + tagValue;
            //viewTitle.tag = kPaneTitleTag + tagValue;
            controlsView.tag = kPaneControlsTag + tagValue;
            
            [innerContainer addSubview:innerPaneView];
            [innerContainer addSubview:viewTitleContainer];
            [innerContainer addSubview:optionButton];
            [innerContainer addSubview:controlsView];
            
            self.automaticallyAdjustsScrollViewInsets = false;
            
            [optionButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *myVal = [NSString stringWithFormat:@"%d.%d",i, j] ;
            NSString *tagString = [NSString stringWithFormat:@"%d",tagValue] ;
            [coordinateDictionary setValue:myVal forKey:tagString];
            tagValue ++ ;
        }
    }
}



- (void)addMultiPaneControlsTwo {
    int	tagValue= 1;
    NSArray *items = [currentPaneType componentsSeparatedByString:@"x"];
    n = [[items objectAtIndex:0]intValue];
    m = [[items objectAtIndex:1]intValue];
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        NSInteger selectedTag = [[tagIndex substringFromIndex:4] integerValue];
        if (selectedTag > m*n) {
            StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
            [streamerVC pauseVideo];
        }
    }
    
    [NSThread sleepForTimeInterval:0.2];
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        NSInteger selectedTag = [[tagIndex substringFromIndex:4] integerValue];
        if (selectedTag > m*n) {
            StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
            [streamerVC manuallyStopPlayback];
        }
        
    }
    
    for ( UIView * innerContainer in [self.containerView subviews]) {
        
        for ( UIView *innerPaneView in innerContainer.subviews) {
            
            [innerPaneView removeFromSuperview];
        }
        
        [innerContainer removeFromSuperview];
    }
    
    fullScreenTagValue = -1;
    Views1 = [NSMutableArray arrayWithCapacity:0]; //------Array of views-----
    coordinateDictionary = [[NSMutableDictionary alloc]init];
    tagFullScreen = [[NSMutableArray alloc]init];
    
    
    for ( int i=0; i< n; i++)
    {
        for ( int j=0; j< m; j++)
        {
            
            CGRect p = [self PaneView:i rows:n cols:m  colval:j];
            UIView  *innerContainer = [[UIView alloc] initWithFrame:p];
            innerContainer.autoresizesSubviews = YES;
            [self.containerView addSubview:innerContainer];
            
            NSDictionary *dict = @{@"view":innerContainer,@"screen_type":@"small"};
            [Views1 addObject:dict];
            
            //---set PanelViewTitle---//
            UIView *viewTitleContainer = [[UIView alloc]
                                          initWithFrame:CGRectMake(0,
                                                                   innerContainer.frame.size.height-30.0,
                                                                   innerContainer.frame.size.width, 30.0)];
            viewTitleContainer.backgroundColor = RGB(48, 48, 50);
            viewTitleContainer.autoresizesSubviews = YES;
            viewTitleContainer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            UILabel *viewTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100, 30.0)];
            [viewTitle setFont:[UIFont systemFontOfSize:12]];
            [viewTitle setBackgroundColor: [UIColor clearColor]];
            [viewTitle setTextColor:[UIColor whiteColor]];
            
            
            UILabel *viewTitleName = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 120, 30.0)];
            [viewTitleName setFont:[UIFont systemFontOfSize:12]];
            [viewTitleName setBackgroundColor: [UIColor clearColor]];
            [viewTitleName setTextColor:[UIColor lightGrayColor]];
            viewTitleName.hidden = YES;
            
            UILabel *viewTitleTime = [[UILabel alloc] initWithFrame:CGRectMake(innerContainer.frame.size.width-60,0,80, 30.0)];
            [viewTitleTime setFont:[UIFont systemFontOfSize:10]];
            [viewTitleTime setBackgroundColor: [UIColor clearColor]];
            [viewTitleTime setTextColor:[UIColor lightGrayColor]];
            
            
            viewTitleContainer.tag = kPaneTitleContainerTag+ tagValue;
            viewTitle.tag = kPaneTitleTag + tagValue;
            viewTitleName.tag = kPaneTitleNameTag+ tagValue;
            viewTitleTime.tag = kPaneTitleTimeTag+ tagValue;
            
            [viewTitleContainer addSubview:viewTitle];
            [viewTitleContainer addSubview:viewTitleName];
            [viewTitleContainer addSubview:viewTitleTime];
            //---End PanelViewTitle---//
            
            UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            optionButton.frame = CGRectMake(innerContainer.frame.size.width - 44 - 5, 0.0, 44.0, 44.0);
            [optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [optionButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
            optionButton.backgroundColor = [UIColor clearColor];
            optionButton.layer.cornerRadius = 10;
            optionButton.clipsToBounds = true;
            
            UIView *controlsView = [[UIView alloc] initWithFrame:CGRectMake(5, innerContainer.frame.size.height - 55, innerContainer.frame.size.width - 10, 50)];
            controlsView.backgroundColor = [UIColor lightGrayColor];
            [controlsView setHidden:YES];
            
            // Mute-Unmute Button
            UIButton *muteUnmuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            muteUnmuteButton.frame = CGRectMake(controlsView.frame.size.width/2 - (44 + 5), 3.0, 44.0, 44.0);
            [muteUnmuteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [muteUnmuteButton addTarget:self action:@selector(muteUnmutePlayer:) forControlEvents:UIControlEventTouchUpInside];
            [muteUnmuteButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
            muteUnmuteButton.backgroundColor = [UIColor clearColor];
            muteUnmuteButton.layer.cornerRadius = 10;
            muteUnmuteButton.clipsToBounds = true;
            muteUnmuteButton.tag = kMuteUnmuteButtonTag + tagValue;
            
            // Play-Pause Button
            UIButton *pausePlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
            pausePlayButton.frame = CGRectMake(muteUnmuteButton.frame.origin.x + muteUnmuteButton.frame.size.width + 5, 3.0, 44.0, 44.0);
            [pausePlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [pausePlayButton addTarget:self action:@selector(pausePlayVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
            [pausePlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            pausePlayButton.backgroundColor = [UIColor clearColor];
            pausePlayButton.layer.cornerRadius = 10;
            pausePlayButton.clipsToBounds = true;
            pausePlayButton.tag = kPausePlayButtonTag + tagValue;
            
            [controlsView addSubview:muteUnmuteButton];
            [controlsView addSubview:pausePlayButton];
            
            UIView *innerPaneView = [[UIView alloc] init];
            innerPaneView.autoresizesSubviews = YES;
            innerPaneView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            innerPaneView.frame = CGRectMake(0, 0, innerContainer.frame.size.width, innerContainer.frame.size.height);
            innerPaneView.backgroundColor  =[UIColor darkGrayColor];
            
            innerContainer.tag = kInnerContainerViewTag + tagValue;
            innerPaneView.tag = kPaneViewTag + tagValue;
            optionButton.tag = kPaneButtonTag + tagValue;
            //viewTitle.tag = kPaneTitleTag + tagValue;
            controlsView.tag = kPaneControlsTag + tagValue;
            
            [innerContainer addSubview:innerPaneView];
            [innerContainer addSubview:viewTitleContainer];
            [innerContainer addSubview:optionButton];
            [innerContainer addSubview:controlsView];
            
            self.automaticallyAdjustsScrollViewInsets = false;
            
            [optionButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *myVal = [NSString stringWithFormat:@"%d.%d",i, j] ;
            NSString *tagString = [NSString stringWithFormat:@"%d",tagValue] ;
            [coordinateDictionary setValue:myVal forKey:tagString];
            tagValue ++;
        }
    }
}

- (void)playBackMethods {
    
    NSArray *items = [currentPaneType componentsSeparatedByString:@"x"];
    n = [[items objectAtIndex:0]intValue];
    m = [[items objectAtIndex:1]intValue];
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        
        //check availablePanels
        NSInteger selectedTag = [[tagIndex substringFromIndex:4] integerValue];
        if (selectedTag <= m*n) {
            UIView *innerContentView = nil;
            StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
            
            UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:selectedTag - 1];
            UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + selectedTag];
            
            if (streamerVC == nil) {
                return;
            }
            ///
            
            id player = [_players objectAtIndex:selectedTag-1];
            if ([player isKindOfClass:[Camera class]]) {
                Camera *ipCamera = (Camera *)player;
                //---Set titleContainer Label---//
                UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + selectedTag];
                UILabel *viewTitle = [viewTitleContainer viewWithTag:kPaneTitleTag + selectedTag];
                
                [viewTitle setText:[NSString stringWithFormat:@"CAM,%@",ipCamera.title]];
                UILabel *viewTitleName = [viewTitleContainer viewWithTag:kPaneTitleNameTag + selectedTag];
                [viewTitleName setText:[NSString stringWithFormat:@"%@",ipCamera.title]];
                
                UILabel *viewTitleTime = [viewTitleContainer viewWithTag:kPaneTitleTimeTag+ selectedTag];
                [viewTitleTime setText:[self getCurrentTimeString]];
                //---End titleContainer Label---//
                ipCamera = nil;
                
            }else if ([player isKindOfClass:[Channel class]]) {
                Channel *channel = (Channel *)player;
                //---Set Camera Title Label---//
                UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + selectedTag];
                UILabel *viewTitle = [viewTitleContainer viewWithTag:kPaneTitleTag + selectedTag];
                //[viewTitle setText:@"TV,"];
                [viewTitle setText:[NSString stringWithFormat:@"TV,%@",channel.channelName]];
                UILabel *viewTitleName = [viewTitleContainer viewWithTag:kPaneTitleNameTag + selectedTag];
                [viewTitleName setText:[NSString stringWithFormat:@"%@",channel.channelName]];
                
                UILabel *viewTitleTime = [viewTitleContainer viewWithTag:kPaneTitleTimeTag+ selectedTag];
                [viewTitleTime setText:[self getCurrentTimeString]];
                //---End Camera Title Label---//
                channel = nil;
            }
            
            
            ///
            NSUInteger toOrientation = [[UIDevice currentDevice] orientation];
            NSLog(@"BEFORE LOOP - BEFORE LOOP - BEFORE LOOP - BEFORE LOOP");
            if (streamerVC) {
                [streamerVC willAnimateRotationToInterfaceOrientation:toOrientation duration:0];
            }
            streamerVC.view.frame = clickedView.frame;
            [clickedView addSubview:streamerVC.view];
            clickedView.autoresizesSubviews = true;

            if ([streamerVC.stateBeforeFullScreen isEqualToString:kVideoStatePause]) {
                streamerVC.stateBeforeFullScreen = kVideoStatePlay;
                [streamerVC playVideo];
            }
            [self dimensionAfterOrientationChange:toOrientation];
        }
    }
    
    //---Only for WebView Playing Block of code---//
    for(int i = 0; i< m*n; i++) {
        id player = [_players objectAtIndex:i];
        if([player isKindOfClass:[UITextField class]]) {
            UITextField *txtFld = (UITextField *)player;
            if ([txtFld.text length] > 0) {
                _webUrl.text = txtFld.text;
                [_players replaceObjectAtIndex:i withObject:_webUrl];
                [self loadWebView:i+1];
            }
        }
    }
}

/*
- (void)playBackMethods {
 
    NSArray *items = [currentPaneType componentsSeparatedByString:@"x"];
    n = [[items objectAtIndex:0]intValue];
    m = [[items objectAtIndex:1]intValue];
    BOOL isAdded = NO;
    [_cameraQueue removeAllObjects];
    for(int i = 0; i< m*n; i++) {
        id player = [_players objectAtIndex:i];
        if ([player isKindOfClass:[Camera class]]) {
            Camera *cam = (Camera *)player;
            if (!isAdded) {
                [self sendIPCameraProbeRequest:cam forTag:i+1];
                isAdded = YES;
            }
            [_cameraQueue addObject:cam];
        }else if ([player isKindOfClass:[Channel class]]) {
            [self loadRTSPStreamerForChannel:(Channel *)player forTag:i+1];
        }
        else if([player isKindOfClass:[UITextField class]]){
            UITextField *txtFld = (UITextField *)player;
            if ([txtFld.text length] > 0) {
                _webUrl.text = txtFld.text;
                [_players replaceObjectAtIndex:i withObject:_webUrl];
                [self loadWebView:i+1];
            }
        }
    }
    
}
*/

/*
- (void)sendIPCameraProbeRequest:(Camera *)ipCamera forTag:(NSInteger)tagValue {
    
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
    
    self.mbProgressHUD = [[MBProgressHUD alloc] initWithView:clickedView];
    self.mbProgressHUD.backgroundColor = [UIColor grayColor];
    [clickedView addSubview:self.mbProgressHUD];
    
    [clickedView bringSubviewToFront:self.mbProgressHUD];
    
    self.mbProgressHUD.delegate = self;
    [self.mbProgressHUD show:YES];
    
    if (self.ipCameraController == nil) {
        self.ipCameraController = [[IPCameraController alloc] init];
        self.ipCameraController.delegate = self;
        
        [self.ipCameraController createGcdAsyncUdpSocketObject];
    }
    
    ipCamera.panelTag = [NSNumber numberWithInteger:tagValue];
    
    //---Set titleContainer Label---//
    UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + tagValue];
    UILabel *viewTitle = [viewTitleContainer viewWithTag:kPaneTitleTag + tagValue];
    //[viewTitle setText:@"CAM,"];
    [viewTitle setText:[NSString stringWithFormat:@"CAM,%@",ipCamera.title]];
    UILabel *viewTitleName = [viewTitleContainer viewWithTag:kPaneTitleNameTag + tagValue];
    [viewTitleName setText:[NSString stringWithFormat:@"%@",ipCamera.title]];
    
    UILabel *viewTitleTime = [viewTitleContainer viewWithTag:kPaneTitleTimeTag+ tagValue];
    [viewTitleTime setText:[self getCurrentTimeString]];
    //---End titleContainer Label---//
    
    [self.ipCameraController setIPAddress:ipCamera.ipAddress withUsername:ipCamera.userName withPassword:ipCamera.password withMediaProfile:@""];
    
    [self.ipCameraController sendProbRequest];
    [_players replaceObjectAtIndex:tagValue-1 withObject:ipCamera];
    
}
*/

- (NSString *)getCurrentTimeString {
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    return [outputFormatter stringFromDate:now];
}

- (void)enterWebURL:(NSInteger )tagValue forAction:(NSString *)buttonAction {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Enter WebURL" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if ([buttonAction isEqual:@"play_web_url"]) {
            
            [self loadWebView:tagValue - kPaneButtonTag];
            [_players replaceObjectAtIndex:(tagValue -1) - kPaneButtonTag withObject:_webUrl];
            
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:OKAction];
    [alert addAction:cancelAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        if ([buttonAction isEqual:@"play_web_url"]) {
            [textField setText:@"http://www.google.com"];
        }
        _webUrl = textField;
        textField.placeholder = @"Enter URL";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark Load WebView

- (void)loadIPCameraView:(NSInteger)tagValue forRowIndex:(NSUInteger)arrIndex {
 
    if (ipCameraViewerObj == nil) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
        ipCameraViewerObj = (IPCameraViewerVC *)[sb instantiateViewControllerWithIdentifier:@"IPCameraViewerVC"];
        
        if (ipCameraController != nil) {
            [ipCameraViewerObj setIPControllerObject:ipCameraController];
            ipCameraViewerObj.isFirstTimeLoadScreen = NO;
        }
        else {
            ipCameraViewerObj.isFirstTimeLoadScreen = YES;
        }
        
        ipCameraViewerObj.multiViewPaneVC = self;
    }

    UserPackage *userPackage = _surroundViewer.userPackages[0];
    Camera *ipCamera = [userPackage.userCameraList objectAtIndex:arrIndex];
    ipCamera.panelTag = [NSNumber numberWithInteger:tagValue];
    //---Set Camera Title Label---//
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
//    UILabel *clickedViewTitle = [clickedParentView viewWithTag:kPaneTitleTag + tagValue];
//    [clickedViewTitle setText:[NSString stringWithFormat:@"CAM,%@",ipCamera.title]];
    
    //---Set titleContainer Label---//
    UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + tagValue];
    UILabel *viewTitle = [viewTitleContainer viewWithTag:kPaneTitleTag + tagValue];
    //[viewTitle setText:@"CAM,"];
    [viewTitle setText:[NSString stringWithFormat:@"CAM,%@",ipCamera.title]];
    UILabel *viewTitleName = [viewTitleContainer viewWithTag:kPaneTitleNameTag + tagValue];
    [viewTitleName setText:[NSString stringWithFormat:@"%@",ipCamera.title]];
    
    UILabel *viewTitleTime = [viewTitleContainer viewWithTag:kPaneTitleTimeTag+ tagValue];
    [viewTitleTime setText:[self getCurrentTimeString]];
    //---End titleContainer Label---//
    
    [ipCameraViewerObj setIpCamera:ipCamera];
    ipCameraViewerObj.isDispalyInMultiPane = YES;
    [self.view addSubview:ipCameraViewerObj.view];
    [_players replaceObjectAtIndex:tagValue-1 withObject:ipCamera];
}

- (void)loadStreamerForVideoURI:(NSString *)videoUri
                       xAddress:(NSString *)xAddress
                       username:(NSString *)username
                       password:(NSString *)password
             isCameraPTZCapable:(BOOL)isCameraPTZCapable
                  isONVIFPlayer:(BOOL)isONVIFPlayer
                ptzProfileToken:(NSString *)ptzProfileToken forPanel:(NSInteger)selectedTag
{
    NSInteger logingFirst = [_surroundViewer.conf.loginFirstTime integerValue];
    if (logingFirst == 0) {
        [ipCameraViewerObj.view removeFromSuperview];
    }
    
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:selectedTag - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + selectedTag];
//    UILabel *clickedViewTitle = [clickedParentView viewWithTag:kPaneTitleTag + selectedTag];
    
    [self loadPlayerControlsForPanelTag:selectedTag show:YES];
    
    [self cleanClickedView:clickedView];
    
    [self muteAllOtherPlayers];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    StreamingVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamingVC"];
    streamingVC.myTagValue = selectedTag;
    streamingVC.isDispalyInMultiPane = YES;
    streamingVC.view.frame = clickedView.frame;
    
    streamingVC.isONVIFPlayer = YES;
    streamingVC.url = [NSURL URLWithString:videoUri];
    streamingVC.xAddr = xAddress;
    streamingVC.username = username;
    streamingVC.password = password;
    streamingVC.ptzProfileToken = ptzProfileToken;
    streamingVC.isCameraPTZCapable = isCameraPTZCapable;
    
    [streamerVCObjects setObject:streamingVC forKey:[NSString stringWithFormat:@"tag_%d",selectedTag] ];

    [clickedView addSubview:streamingVC.view];
    clickedView.autoresizesSubviews = true;
    
    NSUInteger toOrientation   = [[UIDevice currentDevice] orientation];
    [self dimensionAfterOrientationChange2:toOrientation];
    
}

- (void)muteAllOtherPlayers {
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVCOther = [streamerVCObjects valueForKey:tagIndex];
        if (![streamerVCOther isAudioMuted]) {
            [streamerVCOther muteAudio];
            
            NSArray *tagData = [tagIndex componentsSeparatedByString:@"_"];
            NSUInteger tagValuePlayer = [[tagData objectAtIndex:1] integerValue];
            
            UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValuePlayer - 1];
            
            UIView *controlView = [clickedParentView viewWithTag:kPaneControlsTag + tagValuePlayer];
            [controlView setHidden:YES];
            
            for (UIView *subView in [controlView subviews]) {
                if (![subView isKindOfClass:[UIButton class]]) {
                    continue;
                }
                UIButton *controlButton = (UIButton *)subView;
                if ([controlButton tag] - kMuteUnmuteButtonTag < 10) {
                    //Volumne button
                    [controlButton setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
}


- (void)loadPlayerControlsForPanelTag:(NSUInteger)tagValue show:(BOOL)isVisible{
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    
    UIView *controlView = [clickedParentView viewWithTag:kPaneControlsTag + tagValue];
    [controlView setHidden:YES];
//    [controlView setHidden:!isVisible];
    
    for (UIView *subView in [controlView subviews]) {
        if (![subView isKindOfClass:[UIButton class]]) {
            continue;
        }
        UIButton *controlButton = (UIButton *)subView;
        if ([controlButton tag] - kMuteUnmuteButtonTag < 10) {
            //Volumne button
            [controlButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
            
        }
        else {
            // Play-Pause button
            [controlButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        }
    }
}

- (void)loadRTSPStreamerForChannel:(Channel *)channel forTag:(NSInteger)tagValue {
    
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
    [_players replaceObjectAtIndex:tagValue-1 withObject:channel];
    
//    UILabel *clickedViewTitle = [clickedParentView viewWithTag:kPaneTitleTag + tagValue];
//    [clickedViewTitle setText:[NSString stringWithFormat:@"TV,%@",[channel valueForKey:@"channelName"]]];
    //---Set Camera Title Label---//
    UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + tagValue];
    UILabel *viewTitle = [viewTitleContainer viewWithTag:kPaneTitleTag + tagValue];
    //[viewTitle setText:@"TV,"];
    [viewTitle setText:[NSString stringWithFormat:@"TV,%@",channel.channelName]];
    UILabel *viewTitleName = [viewTitleContainer viewWithTag:kPaneTitleNameTag + tagValue];
    [viewTitleName setText:[NSString stringWithFormat:@"%@",channel.channelName]];
    
    UILabel *viewTitleTime = [viewTitleContainer viewWithTag:kPaneTitleTimeTag+ tagValue];
    [viewTitleTime setText:[self getCurrentTimeString]];
    //---End Camera Title Label---//
    
    [self cleanClickedView:clickedView];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    StreamingVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamingVC"];
    streamingVC.isDispalyInMultiPane = YES;
    streamingVC.myTagValue = tagValue;
    streamingVC.view.frame = clickedView.frame;
    
    
    streamingVC.url = [NSURL URLWithString:channel.url];
    streamingVC.isONVIFPlayer = NO;
    streamingVC.xAddr = @"";
    streamingVC.username = @"";
    streamingVC.password = @"";
    streamingVC.ptzProfileToken = @"";
    streamingVC.isCameraPTZCapable = NO;
    
    [streamerVCObjects setObject:streamingVC forKey:[NSString stringWithFormat:@"tag_%ld",(long)tagValue] ];
    
    [clickedView addSubview:streamingVC.view];
    clickedView.autoresizesSubviews = true;
    
    NSUInteger toOrientation   = [[UIDevice currentDevice] orientation];
    [self dimensionAfterOrientationChange2:toOrientation];
}


- (void)loadRTSPStreamer:(NSInteger )tagValue forArrIndex:(NSUInteger)arrIndex{
    NSString *rtspURL = _webUrl.text;

    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];

    
    
    [self loadPlayerControlsForPanelTag:tagValue show:YES];
    
//    FriendsCamera *fCamera = [_surroundViewer.friendsCameras.rows objectAtIndex:arrIndex];
//    [clickedViewTitle setText:[NSString stringWithFormat:@"RTSP - %@",fCamera.name]];
    
    //--For testing purpose
//    NSDictionary *cameraDict = [userCameras objectAtIndex:arrIndex];
//    UILabel *clickedViewTitle = [clickedParentView viewWithTag:kPaneTitleTag + tagValue];
//    if ([cameraDict valueForKey:CIC_PLUGIN_CAMERA_TITLE] != nil) {
//        [clickedViewTitle setText:[NSString stringWithFormat:@"RTSP - %@",[cameraDict valueForKey:CIC_PLUGIN_CAMERA_TITLE]]];
//    }
//    else {
//        [clickedViewTitle setText:[NSString stringWithFormat:@"RTSP - %@",[cameraDict valueForKey:CIC_PLUGIN_CAMERA_IP]]];
//    }
    //--For testing purpose|
    
    [self cleanClickedView:clickedView];
    
    [self muteAllOtherPlayers];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    StreamingVC *streamingVC = [sb instantiateViewControllerWithIdentifier:@"StreamingVC"];
    streamingVC.isDispalyInMultiPane = YES;
    streamingVC.myTagValue = tagValue;
    streamingVC.view.frame = clickedView.frame;
    
    
    streamingVC.url = [NSURL URLWithString:rtspURL];
    streamingVC.isONVIFPlayer = NO;
    streamingVC.xAddr = @"";
    streamingVC.username = @"";
    streamingVC.password = @"";
    streamingVC.ptzProfileToken = @"";
    streamingVC.isCameraPTZCapable = NO;
    
    [streamerVCObjects setObject:streamingVC forKey:[NSString stringWithFormat:@"tag_%d",tagValue] ];
    
    [clickedView addSubview:streamingVC.view];
    
    clickedView.autoresizesSubviews = true;
    
    NSUInteger toOrientation   = [[UIDevice currentDevice] orientation];
    [self dimensionAfterOrientationChange2:toOrientation];
}

- (void)loadWebView:(NSInteger )tagValue {
	
	NSString *enteredWebUrl = _webUrl.text;

    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
    
//    UILabel *clickedViewTitle = [clickedParentView viewWithTag:kPaneTitleTag + tagValue];
//    //[clickedViewTitle setHidden:YES];
//    [clickedViewTitle setText:[NSString stringWithFormat:@"Web,Chrome"]];
    //---Set Camera Title Label---//
    UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + tagValue];
    UILabel *viewTitle = [viewTitleContainer viewWithTag:kPaneTitleTag + tagValue];
    //[viewTitle setText:@"Web,"];
    [viewTitle setText:@"Web,Safari"];
    UILabel *viewTitleName = [viewTitleContainer viewWithTag:kPaneTitleNameTag + tagValue];
    [viewTitleName setText:@"Safari"];
    
    UILabel *viewTitleTime = [viewTitleContainer viewWithTag:kPaneTitleTimeTag+ tagValue];
    [viewTitleTime setText:[self getCurrentTimeString]];
    //---End Camera Title Label---//
    
    
	[self cleanClickedView:clickedView];
    
	UIWebView *myWebView = [[UIWebView alloc]initWithFrame:clickedView.frame];
	myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	myWebView.scalesPageToFit = YES;
	myWebView.delegate = self;
    myWebView.tag = kWebViewTag;
	
	[clickedView addSubview:myWebView];
	clickedView.autoresizesSubviews = true;

	if ([enteredWebUrl rangeOfString:@"http://"].location == NSNotFound) {
		enteredWebUrl =  [@"http://" stringByAppendingString:enteredWebUrl];
	}
	
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:enteredWebUrl]]];
	
    NSUInteger toOrientation   = [[UIDevice currentDevice] orientation];
    [self dimensionAfterOrientationChange:toOrientation];
}

- (void)startRecord:(id)sender {
    NSLog(@"Start Record Button Tapped.");

}

- (void)muteUnmutePlayer:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSUInteger tagValue = [btn tag] - kMuteUnmuteButtonTag;
//    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
//    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
    
    StreamingVC *streamerVC = [streamerVCObjects valueForKey:[NSString stringWithFormat:@"tag_%d",tagValue]];
    
    NSLog(@"MUTE UNMUTE @@@@@@@@@@@@@@@@@@@@@@@ TAG:%d",tagValue);
    
    BOOL isAudioMuted = [streamerVC isAudioMuted];
    
    if (isAudioMuted) {
        [self muteAllOtherPlayers];
        
        [streamerVC unmuteAudio];
        [sender setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
    }
    else {
        [streamerVC muteAudio];
        [sender setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
    }
}

- (void)pausePlayVideoPlayer:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSUInteger tagValue = btn.tag - kPausePlayButtonTag;

    StreamingVC *streamerVC = [streamerVCObjects valueForKey:[NSString stringWithFormat:@"tag_%d",tagValue]];
    BOOL isPlaying = [streamerVC isVideoPlaying];
    if (isPlaying) {
        streamerVC.stateBeforeFullScreen = kVideoStatePause;
        [streamerVC pauseVideo];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else {
        streamerVC.stateBeforeFullScreen = kVideoStatePlay;
        
        [self muteAllOtherPlayers];
        [streamerVC playVideo];

        UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
        
        UIView *controlView = [clickedParentView viewWithTag:kPaneControlsTag + tagValue];
        [controlView setHidden:YES];
        
        for (UIView *subView in [controlView subviews]) {
            if (![subView isKindOfClass:[UIButton class]]) {
                continue;
            }
            UIButton *controlButton = (UIButton *)subView;
            if ([controlButton tag] - kMuteUnmuteButtonTag < 10) {
                //Volumne button
                [controlButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
            }
        }
        
        [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

- (void)clearCurrentPanel:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSUInteger tagValue = [btn tag] - kPaneButtonTag;
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
    
    UILabel *clickedViewTitle = [clickedParentView viewWithTag:kPaneTitleTag + tagValue];
    [clickedViewTitle setHidden:YES];
    
    [self loadPlayerControlsForPanelTag:tagValue show:NO];
    
    [self cleanClickedView:clickedView];
}

- (void)cleanClickedView:(UIView *)clickedView {
    
    NSString *tag = [NSString stringWithFormat:@"tag_%d",[clickedView tag]-kPaneViewTag];
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        
        if ([tagIndex isEqualToString:tag]) { //test this condition is streamer object found OR NOT VERY VERY IMP kPaneViewTag
            StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
            [streamerVC pauseVideo];
            [streamerVC manuallyStopPlayback];
            
            [streamerVCObjects removeObjectForKey:tagIndex];
        }
    }
    
    for (int i= 0; i < [clickedView.subviews count ]; i++) {
        
        if ([[clickedView.subviews objectAtIndex:i] isKindOfClass:[UIView class]]) {
            [[clickedView.subviews objectAtIndex:i] removeFromSuperview];
        }
    }
}

- (void)playPauseTap:(UIGestureRecognizer *)gesture {
	
	int viewTag = gesture.view.tag;

    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:viewTag - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + viewTag];
	
	for (int i= 0; i < [clickedView.layer.sublayers count ]; i++) {
		
		if ([[clickedView.layer.sublayers objectAtIndex:i] isKindOfClass:[AVPlayerLayer class]]) {
			AVPlayerLayer *AVPPlayer = (AVPlayerLayer *)[clickedView.layer.sublayers objectAtIndex:i];
			AVPlayer *player = [AVPPlayer player];
			
			if (player.rate == 0.0) {
				[player play];
				
			} else {
				[player pause];
				
			}
		}
	}}

#pragma mark

-(CGRect)PaneView:(int)i rows:(int)rowIndex cols:(int)colIndex  colval:(int)j {
	
	CGFloat x,y, width,height ;
	CGRect XYReturn;
	
	x = margin+(((self.containerView.frame.size.width)-(margin))/colIndex)*(j);
	y = margin+((((self.containerView.frame.size.height)-(margin))/rowIndex))*(i);
	width = (((self.containerView.frame.size.width)-(margin))/colIndex)-(margin);
	height = (((self.containerView.frame.size.height)-(margin))/rowIndex)-(margin);
	XYReturn= CGRectMake(x, y, width, height);
	
	return XYReturn;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self dimensionAfterOrientationChange: interfaceOrientation];
}

- (void)dimensionAfterOrientationChange:(UIInterfaceOrientation)interfaceOrientation {
	
	NSUInteger index=0;
	
    NSArray *items1 = [currentPaneType componentsSeparatedByString:@"x"];
    int paneRow = [[items1 objectAtIndex:0]intValue];
    int paneColumn = [[items1 objectAtIndex:1]intValue];
    
	for ( int i=0; i< n; i++)//-----------------dimension return after orientation change
	{
		for ( int j=0; j< m; j++, index++)
		{
			CGRect p = [self PaneView:i rows:n cols:m  colval:j];
			
			[[[Views1 objectAtIndex:index] valueForKey:@"view"] setFrame:p];
			//NSLog(@"innerContainer tag=%d",(UIView *)[[Views1 objectAtIndex:index] valueForKey:@"view"].tag);
//            NSUInteger tag = 1;
			for (UIView *innerView in [([[Views1 objectAtIndex:index] valueForKey:@"view"]) subviews]){
                //NSLog(@"innerPaneView=innerView=%d & tag=%d",innerView.subviews.count,innerView.tag);
				
                if (innerView.subviews.count == 1 && ![innerView isKindOfClass:[UIButton class]]) {
                    [innerView setFrame:CGRectMake(0, 0, p.size.width, p.size.height)];
                    
//                    for (UIView *streamPlayer in [innerView subviews]) {
//                        [streamPlayer setFrame:CGRectMake(0, 0, p.size.width, p.size.height)];
////                        streamPlayer.autoresizesSubviews = YES;
////                        streamPlayer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//                        
//                    }
                    
                    for (CALayer *playerView in [innerView.layer sublayers]){
                        
                        CGRect newRect = [self PaneView:i rows:paneRow cols:paneColumn  colval:j];
                        [playerView setFrame:CGRectMake(0, 0, newRect.size.width, newRect.size.height)];
                    }
                    
                }
                else if ( innerView.subviews.count == 2) {
                    //for Control View
                    
                    [innerView setFrame:CGRectMake(5, p.size.height - 55, p.size.width - 10, 46)];
                    
                    CGFloat startingXPos = innerView.frame.size.width/2 - (44.0 + 5);
                    NSUInteger controlMargin = 0;
                    for (UIButton *controlButton in [innerView subviews]) {
                        [controlButton setFrame:CGRectMake(startingXPos + controlMargin, 3.0, 44.0, 44.0)];
                        controlMargin += 5 + 44.0;
                    }
                }else if ([innerView isKindOfClass:[UIButton class]]) {
					[innerView setFrame:CGRectMake(p.size.width - 44, 0, 44.0, 40.0)]; //option Button setFrame
				}else if (innerView.subviews.count == 3) {
                    
                    [innerView setFrame:CGRectMake(0 , p.size.height-30.0, p.size.width, 30.0)];
                    ///
                    for (UILabel *labelView in [innerView subviews]) {
                        if (labelView.tag == kPaneTitleTag+index+1) {
                            [labelView setFrame:CGRectMake(0, 0, 100, 30.0)];
                        }
                        else if (labelView.tag == kPaneTitleNameTag+index+1) {
                            [labelView setFrame:CGRectMake(100 , 0, 120, 30.0)];
                        }
                        else if (labelView.tag == kPaneTitleTimeTag+index+1) {
                            [labelView setFrame:CGRectMake(p.size.width-65.0, 0, 60, 30.0)];
                        }
                    }
                }
            }
		}
		
	}
    
    if (fullScreenTagValue > 0) {
        [self zoomInOutPaneTag:fullScreenTagValue];
    }
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
        [streamerVC willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:0];
    }
    
    if (popUpSubViewController != nil) {
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            // Portrait frames
            popUpSubViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
        } else {
            // Landscape frames
            popUpSubViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
	
	[self.view setNeedsDisplay];
}
#pragma mark - Rough Task
- (void)dimensionAfterOrientationChange2:(UIInterfaceOrientation)interfaceOrientation {
    
    NSUInteger index=0;
    
    NSArray *items1 = [currentPaneType componentsSeparatedByString:@"x"];
    int paneRow = [[items1 objectAtIndex:0]intValue];
    int paneColumn = [[items1 objectAtIndex:1]intValue];
    
    for ( int i=0; i< n; i++)//-----------------dimension return after orientation change
    {
        for ( int j=0; j< m; j++, index++)
        {
            CGRect p = [self PaneView:i rows:n cols:m  colval:j];
            
            [[[Views1 objectAtIndex:index] valueForKey:@"view"] setFrame:p];

            for (UIView *innerView in [([[Views1 objectAtIndex:index] valueForKey:@"view"]) subviews]){
                
                if (innerView.subviews.count == 1 && ![innerView isKindOfClass:[UIButton class]]) {
                    
                    [innerView setFrame:CGRectMake(0, 0, p.size.width, p.size.height)];
                    
                    for (CALayer *playerView in [innerView.layer sublayers]){
                        
                        CGRect newRect = [self PaneView:i rows:paneRow cols:paneColumn  colval:j];
                        [playerView setFrame:CGRectMake(0, 20, newRect.size.width, newRect.size.height)];
                    }
                    
                }
                else if ( innerView.subviews.count == 2) {
                    //for Control View
                    
                    [innerView setFrame:CGRectMake(5, p.size.height - 55, p.size.width - 10, 46)];
                    
                    CGFloat startingXPos = innerView.frame.size.width/2 - (44.0 + 5);
                    NSUInteger controlMargin = 0;
                    for (UIButton *controlButton in [innerView subviews]) {
                        [controlButton setFrame:CGRectMake(startingXPos + controlMargin, 3.0, 44.0, 44.0)];
                        controlMargin += 5 + 44.0;
                    }
                }else if ([innerView isKindOfClass:[UIButton class]]) {
                    [innerView setFrame:CGRectMake(p.size.width - 44, 0, 44.0, 40.0)]; //option Button setFrame
                }else if (innerView.subviews.count == 3) {
                    [innerView setFrame:CGRectMake(0 , p.size.height-30.0, p.size.width, 30.0)];
                    ///
                    for (UILabel *labelView in [innerView subviews]) {
                        if (labelView.tag == kPaneTitleTag+index+1) {
                            [labelView setFrame:CGRectMake(0, 0, 100, 30.0)];
                        }
                        else if (labelView.tag == kPaneTitleNameTag+index+1) {
                            [labelView setFrame:CGRectMake(120, 0, 120, 30.0)];
                        }
                        else if (labelView.tag == kPaneTitleTimeTag+index+1) {
                            [labelView setFrame:CGRectMake(p.size.width-65.0, 0, 60, 30.0)];
                        }
                    }
                    
                }
            }
        }
        
    }
    
    if (fullScreenTagValue > 0) {
        [self zoomInOutPaneTag:fullScreenTagValue];
    }
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:tagIndex];
        [streamerVC willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:0];
    }
    
    [self.view setNeedsDisplay];
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
 
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
 
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSString* errorString = [NSString stringWithFormat:
						  @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
						  error.localizedDescription];
	[webView loadHTMLString:errorString baseURL:nil];
	
}

#pragma mark -

- (void)doSingleTap:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        UIView* view = sender.view;
        NSInteger tagValue = 0;
        
            CGPoint loc = [sender locationInView:view];
            NSLog(@"loc x:%f, y:%f",loc.x, loc.y);
            
            for (UIView *subView in [self.containerView subviews]) {
                if (CGRectContainsPoint(subView.frame, loc)) {
                    tagValue = [subView tag] - kInnerContainerViewTag;
                }
            }
        
        if (tagValue == 0) {
            return;
        }
        
        UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
        UIView *controlView = [clickedParentView viewWithTag:kPaneControlsTag+tagValue];
        
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:[NSString stringWithFormat:@"tag_%d",tagValue]];
        if (streamerVC == nil) {
            BOOL isFoundWebView = NO;
            for (UIView *subSubView in [controlView subviews]) {
                if ([subSubView isKindOfClass:[UIWebView class]]) {
                    isFoundWebView = YES;
                }
            }
            
            if (!isFoundWebView) {
                return;
            }
        }
        
        if ([controlView isHidden]) {
            [controlView setHidden:NO];
        }
        else {
            [controlView setHidden:YES];
        }
    }
}

- (void)doDoubleTap:(UITapGestureRecognizer *)sender {
    
    UIView* view = sender.view;
    
    NSInteger tagValue = fullScreenTagValue;

    if (tagValue < 0) {
        CGPoint loc = [sender locationInView:view];
        NSLog(@"loc x:%f, y:%f",loc.x, loc.y);
        
        for (UIView *subView in [self.containerView subviews]) {
            if (CGRectContainsPoint(subView.frame, loc)) {
                tagValue = [subView tag] - kInnerContainerViewTag;
            }
        }
    }

    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        StreamingVC *streamerVC = [streamerVCObjects valueForKey:[NSString stringWithFormat:@"tag_%d",tagValue]];
        if (streamerVC == nil){
            
            //Check is Webview Load or not
            UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
            UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
            
            BOOL isWebViewLoad = NO;
            for (UIView *subSubView in [clickedView subviews]) {
                if ([subSubView isKindOfClass:[UIWebView class]]) {
                    isWebViewLoad = YES;
                    break;
                }
            }
            
            if (!isWebViewLoad) {
                return;
            }
        }
        
        if (fullScreenTagValue < 0) {
            fullScreenTagValue = tagValue;
        }
        else {
            fullScreenTagValue = -1;
        }
        
        [self zoomInOutPaneTag:tagValue];
    }
}

- (void)zoomInOutPaneTag:(NSUInteger)tagValue {
    
    UIView *innerContentView = nil;
    StreamingVC *streamerVC = [streamerVCObjects valueForKey:[NSString stringWithFormat:@"tag_%d",tagValue]];
    
    UIView *clickedParentView = [[self.containerView subviews] objectAtIndex:tagValue - 1];
    UIView *clickedView = [clickedParentView viewWithTag:kPaneViewTag + tagValue];
    
    if (streamerVC != nil) {
        innerContentView = streamerVC.view;
    }
    else {
        for (UIView *subSubView in [clickedView subviews]) {
            if ([subSubView isKindOfClass:[UIWebView class]]) {
                innerContentView = subSubView;
            }
        }
    }
    
    if (innerContentView == nil) {
        return;
    }
    
    NSString *tagString = [NSString stringWithFormat:@"%d", tagValue];
    NSString *value = [coordinateDictionary objectForKey:tagString];
    NSArray *items = [value componentsSeparatedByString:@"."];
    int i = [[items objectAtIndex:0] integerValue];
    int j = [[items objectAtIndex:1] integerValue];
    
    CGRect oldPanelRect = [self PaneView:i rows:n cols:m colval:j];
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGRect fullScreenFrame = {-(oldPanelRect.origin.x),-(oldPanelRect.origin.y), self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight};
    
    // handling code
    
    CGRect newFrame;
    BOOL isFullScreen = NO;
    
    NSUInteger toOrientation = [[UIDevice currentDevice] orientation];
    
    if (CGSizeEqualToSize(innerContentView.frame.size, fullScreenFrame.size)) {
        //Already in FullScreen
        isFullScreen = NO;
        newFrame = oldPanelRect;
        
        //Main Container
        clickedParentView.frame = newFrame;
        
        // Player
        //        streamerVC.view.frame = CGRectMake(0, 5, newFrame.size.width, newFrame.size.height);
        innerContentView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
        
        if (streamerVC) {
            [streamerVC willAnimateRotationToInterfaceOrientation:toOrientation duration:0];
        }
        
        [self dimensionAfterOrientationChange:toOrientation];
        //        proper frame not set after ZoomOut player
    }
    else {
        // Make view in full-screen
        newFrame = CGRectMake(0, 0, fullScreenFrame.size.width, fullScreenFrame.size.height);
        isFullScreen = YES;
        
        //Main Container
        clickedParentView.frame = CGRectMake(5,5, newFrame.size.width, newFrame.size.height);
        innerContentView.frame = CGRectMake(0,0, newFrame.size.width, newFrame.size.height);
        
        // Edit button
        UIButton *editButton = (UIButton *)[clickedParentView viewWithTag:kPaneButtonTag + tagValue];
        [editButton setFrame:CGRectMake(newFrame.size.width - 44, 0, 44.0, 40.0)];
        
        // Title Label
        
//        UILabel *titleLabel = (UILabel *)[clickedParentView viewWithTag:kPaneTitleTag + tagValue];
//        [titleLabel setFrame:CGRectMake(0 , 0, newFrame.size.width, 40)];
        //---Set titleContainer Position---//
        UIView *viewTitleContainer = [clickedParentView viewWithTag:kPaneTitleContainerTag + tagValue];
        [viewTitleContainer setFrame:CGRectMake(0 , newFrame.size.height-30, newFrame.size.width, 35)];
        //---End titleContainer Position---//
        
        NSLog(@"BEFORE LOOP - BEFORE LOOP - BEFORE LOOP - BEFORE LOOP");
        if (streamerVC) {
//            for (NSString *tagIndex in [streamerVCObjects allKeys]) {
//                StreamingVC *streamerVCOther = [streamerVCObjects valueForKey:tagIndex];
//                if ([tagIndex isEqualToString:[NSString stringWithFormat:@"tag_%d",tagValue]]) {
            
                    // Player
                    //                streamerVC.view.frame = CGRectMake(0, 5, newFrame.size.width, newFrame.size.height);
                    [streamerVC willAnimateRotationToInterfaceOrientation:toOrientation duration:0];
                    
                    // Control View
                    UIView *controlView = [clickedParentView viewWithTag:kPaneControlsTag+tagValue];
                    [controlView setFrame:CGRectMake(5, newFrame.size.height - 60, newFrame.size.width - 10, 46)];
                    
                    CGFloat startingXPos = controlView.frame.size.width/2 - (44.0 + 5);
                    NSUInteger controlMargin = 0;
                    for (UIButton *controlButton in [controlView subviews]) {
                        [controlButton setFrame:CGRectMake(startingXPos + controlMargin, 3.0, 44.0, 44.0)];
                        controlMargin += 5 + 44.0;
                    }
//                }
//            }
        }
    }
    
    clickedView.frame = CGRectMake(0, 0, clickedParentView.frame.size.width, clickedParentView.frame.size.height);
    
    for (NSString *tagIndex in [streamerVCObjects allKeys]) {
        StreamingVC *streamerVCOther = [streamerVCObjects valueForKey:tagIndex];
        if (![tagIndex isEqualToString:[NSString stringWithFormat:@"tag_%d",tagValue]]) {
            
            // Resume playing after zoom-in or zoom-out
            
            if (isFullScreen) {
                if ([streamerVCOther isVideoPlaying]) {
                    streamerVCOther.stateBeforeFullScreen = kVideoStatePlay;
                    [streamerVCOther pauseVideo];
                }
                else {
                    streamerVCOther.stateBeforeFullScreen = kVideoStatePause;
                }
            }
            else {
                if ([streamerVCOther.stateBeforeFullScreen isEqualToString:kVideoStatePlay] && ![streamerVCOther isVideoPlaying]) {
                    [streamerVCOther playVideo];
                }
            }
        }
    }
    
    
    for (UIView *view in [self.containerView subviews]) {
        if (view.tag != tagValue + kInnerContainerViewTag) {
            [view setHidden:isFullScreen];
        }
    }
}

#pragma mark - IPCameraControllerDelegate Methods
/*
- (void)notifyOnError:(NSString *)status error:(NSString *)message; {
    
    [self.mbProgressHUD hide:YES];
//    [self.navigationItem.rightBarButtonItem setEnabled:YES]; // Disables the button
//    [mbProgressHUDInitial hide:YES];
    [self showAlertMessage:@"Error" message:message];
}

- (void)notifyStatusUpdate:(NSString *)status withResponse:(NSDictionary *)responseDic {
    
    //[self.mbProgressHUD hide:YES];
    if ([status isEqualToString:kCameraDatetimeAPIResponse]) {
        // Get media profiles
//        self.mbProgressHUD.labelText = @"Getting Camera Details...";
//        [self.mbProgressHUD show:YES];
        
        [self.ipCameraController getCameraMediaProfiles:[responseDic valueForKey:@"xAddress"]];
    }
    else if ([status isEqualToString:kStreamURIAPIResponse]) {
        
        [self.ipCameraController getPtzCapabilities:[responseDic valueForKey:@"xAddress"] mediaURI:[responseDic valueForKey:@"mediaUri"] profileToken:[responseDic valueForKey:@"profileToken"]];
    }
    else if ([status isEqualToString:kMediaProfileAPIResponse]) {
        NSDictionary *profilesDic = [[[responseDic valueForKey:KEY_BODY] valueForKey:GET_PROFILES_RESPONSE] valueForKey:PROFILES];
    
        NSMutableArray *arrProfileList = [self getMediaProfile:profilesDic];
        ptzProfileTokenVal = [self getPtzProfileToken:profilesDic];
        
        NSString *mediaProfileToken = [[arrProfileList objectAtIndex:0] valueForKey:@"Token"];
        [self.ipCameraController getCameraStreamURI:selectedIPCameraAddress withProfileToken:mediaProfileToken];
    }
    else if ([status isEqualToString:kPTZCapabilitiesAPIResponse]) {

        NSDictionary *ptzDic = [[[[responseDic valueForKey:KEY_BODY] valueForKey:GET_CAPABILITIES_RESPONSE] valueForKey:CAPABILITIES] valueForKey:PTZ];
        
        NSString *xAddr = @"";
        BOOL isPTZEnabled = NO;
        if(ptzDic != nil)
        {
            xAddr = [ptzDic valueForKey:XADDR];
            isPTZEnabled = YES;
        }
        else
        {
            xAddr = [responseDic valueForKey:@"xAddress"];
        }
        
        Camera *ipCamera = [self poll:_cameraQueue];

        [self.mbProgressHUD hide:YES];
        NSString *videoUri = [[responseDic valueForKey:@"mediaUri"] stringByReplacingOccurrencesOfString:@"rtsp://" withString:[NSString stringWithFormat:@"rtsp://%@:%@@",ipCamera.userName,ipCamera.password]];
        
        [self loadStreamerForVideoURI:videoUri xAddress:xAddr username:ipCamera.userName password:ipCamera.password isCameraPTZCapable:isPTZEnabled isONVIFPlayer:YES ptzProfileToken:ptzProfileTokenVal forPanel:ipCamera.panelTag.integerValue];
        
        if (_cameraQueue.count > 0) {
            Camera *ipCamera = [_cameraQueue firstObject];
            [self sendIPCameraProbeRequest: ipCamera forTag:ipCamera.panelTag.integerValue];
        }
//        else if (_cameraQueue.count == 0) {
//            NSArray *items = [currentPaneType componentsSeparatedByString:@"x"];
//            n = [[items objectAtIndex:0]intValue];
//            m = [[items objectAtIndex:1]intValue];
//            if (m*n>2) {
//                [self performSelector:@selector(loadTVWithDelay) withObject:nil afterDelay:1.0];
//            }
//        }
        
    }
    else if ([status isEqualToString:kMediaCapabilitiesAPIResponse]) {
        // Set MediaUri here
        NSString *xAddress = [[[[[responseDic valueForKey:KEY_BODY] valueForKey:GET_CAPABILITIES_RESPONSE] valueForKey:CAPABILITIES] valueForKey:MEDIA] valueForKey:XADDR];
        
        if (xAddress) {
            
            NSArray *xAddrs = [xAddress componentsSeparatedByString:@" "];
            
            // check if any xAddrs in list
            if (xAddrs && [xAddrs count] != 0)
            {
                selectedIPCameraAddress = [xAddrs objectAtIndex:0];
                [self.ipCameraController getCameraMediaProfiles:[xAddrs objectAtIndex:0]];
            }
        }
    }
    else if ([status isEqualToString:kSendProbeRequest]) {

    }
}
*/

- (void)loadTVWithDelay {
//    [self.navigationItem.rightBarButtonItem setEnabled:YES]; // Disables the button
//    [mbProgressHUDInitial hide:YES];

    UserPackage *userPackage = _surroundViewer.userPackages[0];
    ChanelCategory *channelCategory = [userPackage.tvCCategoryList objectAtIndex:0];
    Channel *channel = [channelCategory.channels objectAtIndex:0];
    [self loadRTSPStreamerForChannel:channel forTag:3003 - kPaneButtonTag];

}
#pragma mark - IP Camera Methods

- (void)showAlertMessage:(NSString *)title
                 message:(NSString *)message
{
    [self.mbProgressHUD hide:YES];
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (NSMutableArray *)getMediaProfile:(NSDictionary *)profilesDic
{
    NSMutableArray *arrProfiles = [[NSMutableArray alloc] init];
    
    // If response contains multiple profiles then get the token for profile which has VideoEncoderConfiguration
    NSArray *profilesArray = (NSArray *)profilesDic;
    for (NSDictionary *profile in profilesArray)
    {
        // Get the token for profile which has VideoEncoderConfiguration
        if ([profile valueForKey:VIDEO_ENCODER_CONFIGURATION] != nil)
        {
            NSMutableDictionary *profileDic = [[NSMutableDictionary alloc] init];
            [profileDic setValue:[profile valueForKey:TOKEN] forKey:@"Token"];
            
            NSString *bitRateKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RATE_CONTROL, BITRATE_LIMIT];
            [profileDic setValue:[profile valueForKeyPath:bitRateKeyPath] forKey:@"BitRate"];
            
            
            NSString *fpsKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RATE_CONTROL, FRAME_RATE_LIMIT];
            [profileDic setValue:[profile valueForKeyPath:fpsKeyPath] forKey:@"Fps"];
            
            NSString *heightKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RESOLUTION, HEIGHT];
            [profileDic setValue:[profile valueForKeyPath:heightKeyPath] forKey:@"Height"];
            
            NSString *widthKeyPath = [NSString stringWithFormat:@"%@.%@.%@",VIDEO_ENCODER_CONFIGURATION, RESOLUTION, WIDTH];
            [profileDic setValue:[profile valueForKeyPath:widthKeyPath] forKey:@"Width"];
            
            [arrProfiles addObject:profileDic];
        }
    }
    return arrProfiles;
}

//Get Appropriate PTZ Media Profile token for PTZ Operations
- (NSString *)getPtzProfileToken:(NSDictionary *)profilesDic
{
    NSDictionary *profileDic;
    
    // If response contains multiple profiles then get the token for profile which has VideoEncoderConfiguration
    NSArray *profilesArray = (NSArray *)profilesDic;
    for (NSDictionary *profile in profilesArray)
    {
        // Get the token for profile which has VideoEncoderConfiguration
        if ([profile valueForKey:PTZ_CONFIGURATION] != nil)
        {
            profileDic = profile;
            break;
        }
    }
    
    return [profileDic valueForKey:TOKEN];;
}


#pragma mark - Progress delegate

- (BOOL)isShowing {
    return NO;
}

- (void)close {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_hud hide:YES];
        _hud = nil;
    });
}

- (void)message:(NSString*)msg andTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [_alertController addAction:_okAction];
        [self presentViewController:_alertController animated:YES completion:nil];
    });
}

- (void)msg:(NSString*) msg {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        [_hud hide:YES afterDelay:1.50f];
    });
    
}

- (void)error:(NSString *)msg withTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [_alertController addAction:_okAction];
        [self presentViewController:_alertController animated:YES completion:nil];
    });
}

- (void)error:(NSString*)msg {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [_alertController addAction:_okAction];
        [self presentViewController:_alertController animated:YES completion:nil];
    });
}

- (void)toast:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_hud hide:YES];
        _hud = nil;
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeText;
        //_hud.margin = 0.0f;
        _hud.removeFromSuperViewOnHide = YES;
        _hud.square = NO;
        [_hud hide:YES afterDelay:1.50f];
    });
}

- (void)err:(NSString *)msg withTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [_alertController addAction:_okAction];
        [self presentViewController:_alertController animated:YES completion:nil];
    });
}

- (void)err:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
        [_alertController addAction:_okAction];
        [self presentViewController:_alertController animated:YES completion:nil];
    });
}

#pragma mark - load local
- (void)onLoadLocalUpdater {
    
    NSLog(@"MultiPaneViewController onLoadLocalUpdater ...");
    [_loginVC updateUI];
    if([_loginVC isEmpty]) {
        NSLog(@"MultiPaneViewController onLoadLocalUpdater empty");
        [self loadLoginPanel];
    }
    NSLog(@"MultiPaneViewController onLoadLocalUpdater done");
}

- (void)loadLoginPanel {
    _fromlogin = YES;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_loginVC];
    [self presentViewController:navController animated:YES completion:nil];

}

#pragma mark - Login Updater Delegate

- (void)loginSuccess:(BOOL)success {
    _fromlogin = NO;
    if (!success) {
        [self loadLoginPanel];
    }else {
        [self onLoadLocalUpdater];
    }
    
}

#pragma mark - Updater Delegate
- (void)update{
    //---save to json---//
    NSInteger logingFirst = [_surroundViewer.conf.loginFirstTime integerValue];
    if (logingFirst == 1) {
        _surroundViewer.conf.loginFirstTime = 0;
        [JsonUtil saveObject:_surroundViewer.conf withFile:@"conf"];
        
    }
    if (!self.isDefaultVideoLoaded) {
        [self onUpdate];
    }
    
}

- (void)onUpdate{
    //dispatch_async(dispatch_get_main_queue(), ^(void){
    [_loginVC updateUI];
    
    if(_surroundViewer.userPackages.count > 0 ){

//        _cameraQueue = [[NSMutableArray alloc] initWithCapacity:4];
        UserPackage *userPackage = _surroundViewer.userPackages[0];
        if (userPackage.userCameraList.count > 0) {
            //---Initial Panel Settings---//
            self.isDefaultVideoLoaded = YES;
            //---End Initial Panel Settings---//
            ChanelCategory *channelCategory = [userPackage.tvCCategoryList objectAtIndex:0];
            Channel *channel = [channelCategory.channels objectAtIndex:0];
            [self loadRTSPStreamerForChannel:channel forTag:3001 - kPaneButtonTag];
            
        }
    }

    //});
}

- (id)poll:(NSMutableArray *)queue {
    id headObject = [queue objectAtIndex:0];
    if (headObject != nil) {
        [queue removeObjectAtIndex:0];
    }
    return headObject;
}
@end
