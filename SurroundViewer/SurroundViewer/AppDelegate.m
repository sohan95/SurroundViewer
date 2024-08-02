//
//  AppDelegate.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 6/7/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstTabViewController.h"

#import "StreamerConfiguration.h"
#import "Constant.h"

#import "StreamVideoVC.h"
#import "MultiPaneViewController.h"
#import "SurroundDefine.h"
//#import "StreamConfig.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//#include "IPAddress.h"

#define AppVersion @"AppVersion"

@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_camera"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ip_camera"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    if (launchOptions == nil || ![launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
    //
    //        NSLog(@"in if");
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cisco Instant Connect App needs to be running for the Video Connect Plugin to operate." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //
    //        alertView.delegate = self;
    //        [alertView show];
    //
    //        MultiPaneViewController *multiPaneVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MultiPaneViewController"]; //or the homeController
    //        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:multiPaneVC];
    //        self.window.rootViewController = navController;
    //    }
    
    StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
    [streamerConfig setDefaultConfiguration];
    
    [self saveDeviceInfomation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if ([defaults valueForKey:AppVersion] != nil)
    {
        if (![[NSString stringWithFormat:@"%@",[defaults valueForKey:AppVersion]] isEqualToString:version])
        {
            [defaults setObject:version forKey:AppVersion];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
        [defaults setObject:version forKey:AppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDictionary *appDefaults = @{kVLCSettingPasscodeKey : @"", kVLCSettingPasscodeOnKey : @(NO), kVLCSettingStretchAudio : @(NO), kVLCSettingTextEncoding : kVLCSettingTextEncodingDefaultValue, kVLCSettingSubtitlesFont : kVLCSettingSubtitlesFontDefaultValue, kVLCSettingSubtitlesFontColor : kVLCSettingSubtitlesFontColorDefaultValue, kVLCSettingSubtitlesFontSize : kVLCSettingSubtitlesFontSizeDefaultValue, kVLCSettingDeinterlace : kVLCSettingDeinterlaceDefaultValue};
    
    [defaults registerDefaults:appDefaults];
    
     NSArray *userCameraQuery = @[
                                @{CIC_PLUGIN_CAMERA_IP:@"rtsp://admin:Test123@@50.242.178.52:554/StreamingSetting?action=getRTSPStream&ChannelID=1&ChannelName=Channel1",CIC_PLUGIN_CAMERA_USER:@"", CIC_PLUGIN_CAMERA_PASS:@"", CIC_PLUGIN_CAMERA_TITLE:@"Qauim RTSP"},
                                @{CIC_PLUGIN_CAMERA_IP:@"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov",CIC_PLUGIN_CAMERA_USER:@"", CIC_PLUGIN_CAMERA_PASS:@"", CIC_PLUGIN_CAMERA_TITLE:@"RTSP 1"},
     @{CIC_PLUGIN_CAMERA_IP:@"rtsp://10.12.0.25:8555/IPICSStream",CIC_PLUGIN_CAMERA_USER:@"", CIC_PLUGIN_CAMERA_PASS:@"", CIC_PLUGIN_CAMERA_TITLE:@"RTSP 2"},
     @{CIC_PLUGIN_CAMERA_IP:@"rtsp://10.103.3.170:1935/live/myStream",CIC_PLUGIN_CAMERA_USER:@"", CIC_PLUGIN_CAMERA_PASS:@"", CIC_PLUGIN_CAMERA_TITLE:@"RTSP 2"},
     @{CIC_PLUGIN_CAMERA_IP:@"rtsp://10.100.23.39:1935/vod/sample1.mp4",CIC_PLUGIN_CAMERA_USER:@"", CIC_PLUGIN_CAMERA_PASS:@"", CIC_PLUGIN_CAMERA_TITLE:@"RTSP 3"},
     
     
     @{CIC_PLUGIN_CAMERA_IP:@"rtsp://10.100.23.39:1935/vod/sample3.mp4",CIC_PLUGIN_CAMERA_USER:@"", CIC_PLUGIN_CAMERA_PASS:@"", CIC_PLUGIN_CAMERA_TITLE:@"RTSP 4"}
     ];
     
     
     // @{CIC_PLUGIN_CAMERA_IP:@"10.107.2.77", CIC_PLUGIN_CAMERA_USER:@"admin", CIC_PLUGIN_CAMERA_PASS:@"Cisco123", CIC_PLUGIN_CAMERA_TITLE:@"Camera 1"},
     NSArray *surveillanceCameraIPs = @[
                                        @{CIC_PLUGIN_CAMERA_IP:@"10.107.2.153",      CIC_PLUGIN_CAMERA_USER:@"admin",
                                          CIC_PLUGIN_CAMERA_PASS:@"Cisco123", CIC_PLUGIN_CAMERA_TITLE:@"Camera 2"} ,
                                        @{CIC_PLUGIN_CAMERA_IP:@"50.242.178.52", CIC_PLUGIN_CAMERA_USER:@"admin", CIC_PLUGIN_CAMERA_PASS:@"Test123@", CIC_PLUGIN_CAMERA_TITLE:@"Qauim Camera"}
                                        ];
    
    [[NSUserDefaults standardUserDefaults] setObject:userCameraQuery forKey:@"user_camera"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //Open plater with IP camera
    [[NSUserDefaults standardUserDefaults] setObject:surveillanceCameraIPs forKey:@"ip_camera"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [streamerConfig setWowzaServerIP:@"54.149.54.165"];
    [streamerConfig setWowzaServerPort:@"1935"];
    [streamerConfig setWowzaUsername:@"admin"];
    [streamerConfig setWowzaPassword:@"admin"];
    [streamerConfig setWowzaApplication:@"CiscoIPICSVideoStreamer"];
    [streamerConfig setWowzaStreamName:@"myStream"];
    [streamerConfig setStreamBehaviorType:kStreamBehaviorTypeClient];
    
     /*
     NSString *userCameraJSONEncodedString = [self findJSONEncodedString:userCameraQuery];
     NSString *ipCameraJSONEncodedString = [self findJSONEncodedString:surveillanceCameraIPs];
     
     NSString *paramDict = [NSString stringWithFormat:@"user=%@&ip_camera=%@",userCameraJSONEncodedString, ipCameraJSONEncodedString];
     
     NSString *query = [NSString stringWithFormat:@"?app_behavior=start_playing&%@", paramDict];
     
     [self application:application openURL:[NSURL URLWithString:[NSString stringWithFormat:@"videoconnectplugin://%@",query]] sourceApplication:@"test" annotation:nil];
    */
    
    
    //    [streamerConfig setStreamType:kStreamTypeAudioOnly];
    
    //    NSString *query = @"?app_behavior=start_streaming";
    //
    //    [self application:application openURL:[NSURL URLWithString:[NSString stringWithFormat:@"videoconnectplugin://%@",query]] sourceApplication:@"test" annotation:nil];
    [[UINavigationBar appearance] setBarTintColor:RGB(23, 65, 120)];
    return YES;
}

- (NSString *)findJSONEncodedString:(NSArray *)jsonArr {
    NSError *error = nil;
    NSData *offersJSONData = [NSJSONSerialization dataWithJSONObject:jsonArr options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error != nil) {
        
        NSLog(@"ERROR::%@", [error localizedDescription]);
    }
    
    NSString *offersJSONString = [[NSString alloc] initWithData:offersJSONData encoding:NSUTF8StringEncoding];
    
    offersJSONString = [[offersJSONString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    offersJSONString = [offersJSONString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return offersJSONString;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //ok button pressed
        
        [self manuallyTerminatingApp];
    }
}

- (void)manuallyTerminatingApp {
    NSLog(@"OK action");
    //home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    
    //wait 2 seconds while app is going background
    //    [NSThread sleepForTimeInterval:2.0];
    
    //exit app when app is in background
    exit(0);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    NSLog(@"sourceApplication ***********%@",sourceApplication);
    
    NSLog(@"url recieved: %@", url);
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    
    NSArray *queryItems = [[url query] componentsSeparatedByString:@"&"];
    NSLog(@"queryItems ---------- %@", queryItems);
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *paramObj in queryItems) {
        NSString *key = [paramObj substringToIndex:[paramObj rangeOfString:@"="].location];
        id value = [paramObj substringFromIndex:[paramObj rangeOfString:@"="].location+1];
        
        if ([key isEqualToString:@"user"]) {
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            
            NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
            value = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        }
        else if ([key isEqualToString:@"ip_camera"]) {
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            
            NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
            value = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        }
        
        [paramDict setObject:value forKey:key];
    }
    
    NSLog(@"Dictionary:%@",paramDict);
    
    if ([[paramDict allKeys] containsObject:@"app_behavior"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[paramDict objectForKey:@"app_behavior"] forKey:@"app_behavior"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[paramDict objectForKey:@"app_behavior"] isEqualToString:@"start_streaming"]) {
            //start Streaming client
            
            StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
            
            //            [streamerConfig setWowzaServerIP:@"54.149.54.165"];
            //            [streamerConfig setWowzaServerPort:@"1935"];
            //            [streamerConfig setWowzaUsername:@"publisher420"];
            //            [streamerConfig setWowzaPassword:@"1234"];
            //            [streamerConfig setWowzaApplication:@"live"]; //@"CiscoIPICSVideoStreamer"];
            //            [streamerConfig setWowzaStreamName:@"myStream"];
            
            [streamerConfig setWowzaServerIP:@"10.100.23.70"];
            [streamerConfig setWowzaServerPort:@"1935"];
            [streamerConfig setWowzaUsername:@"admin"];
            [streamerConfig setWowzaPassword:@"admin"];
            [streamerConfig setWowzaApplication:@"live"];
            [streamerConfig setWowzaStreamName:@"myStream"];
            
            [streamerConfig setStreamBehaviorType:kStreamBehaviorTypeClient];
            
            StreamVideoVC *streamVideoVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"StreamVideoVC"]; //or the homeController
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:streamVideoVC];
            self.window.rootViewController = navController;
        }
        else if ([[paramDict objectForKey:@"app_behavior"] isEqualToString:@"start_playing"]) {
            
            StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
            [streamerConfig setSelectedLayoutStyle:kLayoutStyle1x1];
            
            NSString *rtspURL = [paramDict objectForKey:@"user"];
            if (rtspURL != nil) {
                //Open player with rtsp url
                
                [[NSUserDefaults standardUserDefaults] setObject:rtspURL forKey:@"user_camera"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if ([paramDict objectForKey:@"ip_camera"]){
                //Open plater with IP camera
                [[NSUserDefaults standardUserDefaults] setObject:[paramDict objectForKey:@"ip_camera"] forKey:@"ip_camera"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            MultiPaneViewController *multiPaneVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MultiPaneViewController"]; //or the homeController
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:multiPaneVC];
            self.window.rootViewController = navController;
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Save Device Information in DB

- (void)openReturnToInstantConnect {
    //    NSString *query = @"app_behavior=returned";
    
    UIApplication *ourApplication = [UIApplication sharedApplication];
    
    //    NSString *ourPath = [@"instantconnect://" stringByAppendingString:query];
    NSURL *ourURL = [NSURL URLWithString:@"instantconnect://"];
    if ([ourApplication canOpenURL:[NSURL URLWithString:@"instantconnect:"]]) {
        [ourApplication openURL:ourURL];
        
        [self manuallyTerminatingApp];
    }
    else {
        //Display error
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cisco Instant Connect App  not installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        alertView.delegate = self;
        [alertView show];
    }
    
    
}

- (void)saveDeviceInfomation {
    
    NSString* Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
    
    NSString *modelName = [[self getModel] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *hardwearID = [self getMacAddress];
    
    NSDictionary *deviceData = @{@"modelName":modelName, @"hardwearId": hardwearID, @"deviceUUID":Identifier};
    
    StreamerConfiguration *streamerConfig = [StreamerConfiguration sharedInstance];
    [streamerConfig setDefaultDeviceConfiguration:deviceData];
}

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *code = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    NSDictionary *deviceNamesByCode = @{@"i386"      :@"Simulator",
                                        @"x86_64"    :@"Simulator",
                                        @"iPod1,1"   :@"iPod Touch",      // (Original)
                                        @"iPod2,1"   :@"iPod Touch (2nd gen)",      // (Second Generation)
                                        @"iPod3,1"   :@"iPod Touch (3rd gen)",      // (Third Generation)
                                        @"iPod4,1"   :@"iPod Touch (4th gen)",      // (Fourth Generation)
                                        @"iPod5,1"   :@"iPod Touch (5th gen)",      // (Fifth Generation)
                                        @"iPod7,1"   :@"iPod Touch (6th gen)",      // (6th Generation)
                                        @"iPhone1,1" :@"iPhone",          // (Original)
                                        @"iPhone1,2" :@"iPhone",          // (3G)
                                        @"iPhone2,1" :@"iPhone",          // (3GS)
                                        @"iPhone3,1" :@"iPhone 4 (GSM)",        // (GSM)
                                        @"iPhone3,3" :@"iPhone 4 (CDMA)",        // (CDMA/Verizon/Sprint)
                                        @"iPhone4,1" :@"iPhone 4S",       //
                                        @"iPhone5,1" :@"iPhone 5 (A1428)",        // (model A1428, AT&T/Canada)
                                        @"iPhone5,2" :@"iPhone 5 (A1429)",        // (model A1429, everything else)
                                        @"iPhone5,3" :@"iPhone 5c (A1456/A1532)",       // (model A1456, A1532 | GSM)
                                        @"iPhone5,4" :@"iPhone 5c (A1507/A1516/A1529)",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                                        @"iPhone6,1" :@"iPhone 5s (A1433/A1453)",       // (model A1433, A1533 | GSM)
                                        @"iPhone6,2" :@"iPhone 5s (A1457/A1518/A1530)",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                                        @"iPhone7,1" :@"iPhone 6 Plus",   //
                                        @"iPhone7,2" :@"iPhone 6",        //
                                        @"iPhone8,1" :@"iPhone 6s",       //
                                        @"iPhone8,2" :@"iPhone 6s Plus",  //
                                        
                                        @"iPad1,1"   :@"iPad",            // (Original)
                                        @"iPad2,1"   :@"iPad 2",          //
                                        @"iPad2,5"   :@"iPad Mini",       // (Original)
                                        
                                        @"iPad3,1"   :@"iPad",            // (3rd Generation)
                                        @"iPad3,4"   :@"iPad",            // (4th Generation)
                                        @"iPad4,1"   :@"iPad Air (Wi-Fi)",        // 5th Generation iPad (iPad Air) - Wifi
                                        @"iPad4,2"   :@"iPad Air (Wi-Fi+LTE)",        // 5th Generation iPad (iPad Air) - Cellular
                                        @"iPad4,4"   :@"iPad Mini 2 (Wi-Fi)",       // (2nd Generation iPad Mini - Wifi)
                                        @"iPad4,5"   :@"iPad Mini 2 (Wi-Fi+LTE)",       // (2nd Generation iPad Mini - Cellular)
                                        @"iPad4,7"   :@"iPad mini 3 (Wi-Fi)",        // (3rd Generation iPad Mini - Wifi (model A1599))
                                        @"iPad5,1"   :@"iPad mini 4 (Wi-Fi)",
                                        @"iPad5,2"   :@"iPad mini 4 (Wi-Fi+LTE)",
                                        @"iPad5,3"   :@"iPad Air 2 (Wi-Fi)",
                                        @"iPad5,4"   :@"iPad Air 2 (Wi-Fi+LTE)",
                                        @"iPad6,7"   :@"iPad Pro (Wi-Fi)",
                                        @"iPad6,8"   :@"iPad Pro (Wi-Fi+LTE)"
                                        };
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    return deviceName;
}

- (NSString *) getMacAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}

@end
