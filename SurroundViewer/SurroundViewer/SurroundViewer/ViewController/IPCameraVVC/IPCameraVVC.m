//
//  IPCameraVVC.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 6/15/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "IPCameraVVC.h"

@implementation IPCameraVVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RemoveSubView:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getIPCameraNofification"
     object:self userInfo:nil];
}

@end