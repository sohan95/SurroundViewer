//
//  LogInViewController.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Operator.h"
#import "SurroundViewer.h"
@interface LogInViewController : UIViewController
@property (nonatomic, readwrite) SurroundViewer *surroundViewer;
@property id<Operator> serviceOperator;
- (void)updateUI;
- (BOOL)isEmpty;
@end
