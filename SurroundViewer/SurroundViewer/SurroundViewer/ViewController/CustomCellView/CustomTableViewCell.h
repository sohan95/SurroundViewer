//
//  CustomTableViewCell.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 6/1/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet UIImageView *iconView;
@property(nonatomic,strong) IBOutlet UILabel *details;

@end
