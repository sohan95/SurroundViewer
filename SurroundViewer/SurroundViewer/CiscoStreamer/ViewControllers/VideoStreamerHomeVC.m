//
//  VideoStreamerHomeVC.m
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 17/11/15.
//  Copyright © 2015 eInfochips. All rights reserved.
//

#import "VideoStreamerHomeVC.h"
#import "StreamVideoVC.h"
#import "RecordingsVC.h"
#import "SettingsTableViewController.h"

#import "StreamerConfiguration.h"

#import "Constant.h"

#import "MultiPaneViewController.h"
//#import "HomeVC.h"

@interface VideoStreamerHomeVC ()
{
    StreamerConfiguration *streamerConfig;
    
    NSArray *mediaProfiles;
    
    BOOL loadStreamingFirstTimeOnly;
}
@end

@implementation VideoStreamerHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loadStreamingFirstTimeOnly = NO;
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    
    
    CGFloat tabFontSize = 16.0f;
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                       [UIFont fontWithName:@"Helvetica" size:tabFontSize],
                                                       NSFontAttributeName,
                                                       nil] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor blueColor], NSForegroundColorAttributeName,
                                                       [UIFont fontWithName:@"Helvetica" size:tabFontSize], NSFontAttributeName,
                                                       nil] forState:UIControlStateSelected];
    
    streamerConfig = [StreamerConfiguration sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation toInterfaceOrientation:%d",toInterfaceOrientation);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!loadStreamingFirstTimeOnly) {
        loadStreamingFirstTimeOnly = YES;
        
        [self tappedStartStreaming:nil];
    }
}

#pragma mark - Button Actions

- (IBAction)tappedPlayer:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MultiPaneViewController *multiPaneVC = [sb instantiateViewControllerWithIdentifier:@"MultiPaneViewController"];
    [self.navigationController pushViewController:multiPaneVC animated:YES];
}

- (IBAction)tappedSettings:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsTableViewController *settingsVC = [sb instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
    settingsVC.screenTag = 100;
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (IBAction)tappedStartStreaming:(id)sender {
    
    NSString *errorMessgae = @"";
    
    if ( [[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeClient] &&
        (([streamerConfig getWowzaUsername] == nil || [[streamerConfig getWowzaUsername]  length]<=0) ||
        ([streamerConfig getWowzaServerIP] == nil || [[streamerConfig getWowzaServerIP] length]<=0) ||
        ([streamerConfig getWowzaPassword] == nil || [[streamerConfig getWowzaPassword] length]<=0) ||
         ([streamerConfig getWowzaApplication] == nil || [[streamerConfig getWowzaApplication] length]<=0) ||
         ([streamerConfig getWowzaStreamName] == nil || [[streamerConfig getWowzaStreamName] length]<=0)) ) {
        
            errorMessgae = kWowzaServerNotConfigured;
            
    }
    else if ([[streamerConfig getStreamBehaviorType] isEqualToString:kStreamBehaviorTypeServer] && [[streamerConfig isONVIFEnabled] boolValue]) {
        
        mediaProfiles = [streamerConfig getProfiles:nil forProfileName:@""];

        if ([mediaProfiles count] <=0 ){
            errorMessgae = @"Please add atleast one ONVIF profile.";
        }
    }
    
    if (errorMessgae.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessgae delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StreamVideoVC *streamVideoVC = [sb instantiateViewControllerWithIdentifier:@"StreamVideoVC"];
    [self.navigationController pushViewController:streamVideoVC animated:YES];
}

- (IBAction)tappedRecordings:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
    RecordingsVC *recordingVC = [sb instantiateViewControllerWithIdentifier:@"RecordingsVC"];
    [self.navigationController pushViewController:recordingVC animated:YES];
}

@end
