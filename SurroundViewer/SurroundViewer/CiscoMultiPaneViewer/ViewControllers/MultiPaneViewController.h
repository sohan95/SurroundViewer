//
//  firstViewController.h
//  cisco_demo
//
//  Created by einfochips on 2/23/16.
//  Copyright © 2016 einfochips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVKit/AVKit.h>

@interface MultiPaneViewController : UIViewController
{
    
}

- (void)loadStreamerForVideoURI:(NSString *)videoUri xAddress:(NSString *)xAddress username:(NSString *)username password:(NSString *)password isCameraPTZCapable:(BOOL)isCameraPTZCapable isONVIFPlayer:(BOOL)isONVIFPlayer ptzProfileToken:(NSString *)ptzProfileToken forPanel:(NSInteger)selectedTag;
- (void)onLoadLocalUpdater;
- (void)removeIPCameraViewer;

@end
