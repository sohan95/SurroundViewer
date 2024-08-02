//
//  AppDelegate.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 6/7/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (assign, nonatomic) BOOL restrictRotation;
@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
//- (void)openReturnToInstantConnect;
@end

