//
//  RecordingsVC.h
//  CiscoIPICSVideoStreamer
//
//  Created by Apple on 09/11/15.
//  Copyright © 2015 AHMLPT0406. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "FTPRequest.h"

@interface RecordingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, FTPRequestDelegate, MBProgressHUDDelegate>
{
    IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) MBProgressHUD *mBProgressHUD;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
