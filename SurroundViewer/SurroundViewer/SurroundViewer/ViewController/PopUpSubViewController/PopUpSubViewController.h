//
//  PopUpSubViewController.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/19/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SurroundViewer.h"
@interface PopUpSubViewController : UIViewController

@property(nonatomic, readwrite) SurroundViewer *surroundViewer;
@property(nonatomic, assign) NSInteger selectedVideoType;

@end
