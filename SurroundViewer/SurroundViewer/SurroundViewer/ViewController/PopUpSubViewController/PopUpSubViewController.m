//
//  PopUpSubViewController.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/19/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "PopUpSubViewController.h"
#import "Constant.h"
#import "SurroundDefine.h"
#import "CustomTableViewCell.h"

@interface PopUpSubViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, assign)    NSInteger videoType;
@property(nonatomic, strong)    IBOutlet UITableView *tView;

@property(nonatomic, strong) IBOutlet UILabel *tableDataTitle;
@property(nonatomic, strong) IBOutlet UIView *tableViewScreen;
@property(nonatomic, strong) IBOutlet UIView *tableViewScreenTrans;
@property(nonatomic, strong) IBOutlet UIView *tableContainerView;

@property(nonatomic, assign) BOOL isTableReloadAble;

@property(nonatomic, strong) IBOutlet UIView *menuBtnViewScreen;
@property(nonatomic, strong) IBOutlet UIView *menuBtnViewScreenTrans;
@property(nonatomic, strong) IBOutlet UIView *menuBtnContainerView;

@property(nonatomic, strong) IBOutlet UILabel *tableDataIconName;
@property(nonatomic, strong) IBOutlet UIImageView *tableDataIconImageView;

@end

@implementation PopUpSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setShadowOnPopUpView];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    
    //---show/hide---//
    UITapGestureRecognizer *menuTransViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popupViewHideTapHandler:)];
    self.menuBtnViewScreenTrans.tag = 1;
    [self.menuBtnViewScreenTrans addGestureRecognizer:menuTransViewTap];
    
    UITapGestureRecognizer *tableTransViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popupViewHideTapHandler:)];
    self.tableViewScreenTrans.tag = 2;
    [self.tableViewScreenTrans addGestureRecognizer:tableTransViewTap];
    NSLog(@"%@", _surroundViewer);
    self.videoType = kClosePopUpViewCode;
    self.isTableReloadAble = NO;
    //[self setAllViews];
    ///
    [self setShadowOnPopUpView];
    [self hideAllPopupView];
    [self selectedVideoMenu];
    ///
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper Methods -
- (void) setAllViews {
    //---Initialization for Service Call---//
    [self setShadowOnPopUpView];
    [self hideAllPopupView];
    self.menuBtnViewScreen.hidden = NO;
    [self fadeIn:self.menuBtnViewScreen];
    
}

- (void) setShadowOnPopUpView {
    //---set border shadow on menuBtnViewScreen---//
    self.menuBtnContainerView.layer.cornerRadius = 5;
    self.menuBtnContainerView.layer.shadowOffset = CGSizeMake(0, 3);
    self.menuBtnContainerView.layer.shadowRadius = 5.0;
    self.menuBtnContainerView.layer.shadowColor = (__bridge CGColorRef _Nullable)([UIColor colorWithRed: 48/255. green:67/255. blue:87/255. alpha:1]);//RGB(48,67,87).CGColor;
    self.menuBtnContainerView.layer.shadowOpacity = 0.8;
    
    //---set border shadow on menuBtnViewScreen---//
    self.tableContainerView.layer.cornerRadius = 5;
    self.tableContainerView.layer.shadowOffset = CGSizeMake(0, 3);
    self.tableContainerView.layer.shadowRadius = 5.0;
    self.tableContainerView.layer.shadowColor = (__bridge CGColorRef _Nullable)([UIColor colorWithRed: 48/255. green:67/255. blue:87/255. alpha:1]);//RGB(48,67,87).CGColor;
    self.tableContainerView.layer.shadowOpacity = 0.7;
}

- (void)hideAllPopupView {
    self.menuBtnViewScreen.hidden = YES;
    self.tableViewScreen.hidden = YES;
}

- (void) selectedVideoMenu {
    //---Initialization for Service Call---//
    if (_selectedVideoType == 0) {
        self.tableDataTitle.text = @"Select TV Channel";
        self.tableDataIconName.text = @"IP TV";
        [self.tableDataIconImageView setImage:[UIImage imageNamed:@"TVOptionLargeIcone.png"]];
        self.tableViewScreen.hidden = NO;
        [self.tView reloadData];
        [self fadeIn:self.tableViewScreen];
        self.videoType = 0;
        self.isTableReloadAble = YES;
        
    }else if (_selectedVideoType == 1) {
        self.tableDataTitle.text = @"Select Camera";
        self.tableDataIconName.text = @"Camera";
        [self.tableDataIconImageView setImage:[UIImage imageNamed:@"CameraOptionLargeIcone.png"]];
        self.tableViewScreen.hidden = NO;
        [self.tView reloadData];
        [self fadeIn:self.tableViewScreen];
        self.videoType = 1;
        self.isTableReloadAble = YES;
        
    }else if (_selectedVideoType == 2) {
        self.tableDataTitle.text = @"Select Friends CAM";
        self.tableDataIconName.text = @"Friends CAM";
        [self.tableDataIconImageView setImage:[UIImage imageNamed:@"FriendOptionLargeIcone.png"]];
        
        self.tableViewScreen.hidden = NO;
        [self.tView reloadData];
        [self fadeIn:self.tableViewScreen];
        self.videoType = 2;
        self.isTableReloadAble = YES;
    }
    else if (_selectedVideoType == 3) {
        self.tableViewScreen.hidden = YES;
        self.menuBtnViewScreen.hidden = NO;
        [self fadeIn:self.menuBtnViewScreen];
        
    }
    
}

#pragma mark- Actions

- (IBAction)LoadIPTVChannel:(id)sender {

    self.tableDataTitle.text = @"Select TV Channel";
    self.tableDataIconName.text = @"IP TV";
    [self.tableDataIconImageView setImage:[UIImage imageNamed:@"TVOptionLargeIcone.png"]];
    
    [self fadeOutMenuBtnViewScreen];
    self.videoType = 0;
    self.isTableReloadAble = YES;
}

- (IBAction)LoadCamera:(id)sender {
    self.tableDataTitle.text = @"Select Camera";
    self.tableDataIconName.text = @"Camera";
    [self.tableDataIconImageView setImage:[UIImage imageNamed:@"CameraOptionLargeIcone.png"]];
    [self fadeOutMenuBtnViewScreen];
    self.videoType = 1;
    self.isTableReloadAble = YES;
    
}

- (IBAction)LoadFriendsCam:(id)sender {
    self.tableDataTitle.text = @"Select Friends CAM";
    self.tableDataIconName.text = @"Friends CAM";
    [self.tableDataIconImageView setImage:[UIImage imageNamed:@"FriendOptionLargeIcone.png"]];
    [self fadeOutMenuBtnViewScreen];
    self.videoType = 2;
    self.isTableReloadAble = YES;
}

- (IBAction)LoadWebBrowser:(id)sender {
    NSLog(@"LoadWebPage");
    [self fadeOutPopUpView:self.menuBtnViewScreen];
    self.videoType = 3;
}

- (IBAction)CloseBtnAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    self.isTableReloadAble = NO;
    self.videoType = kClosePopUpViewCode;
    if (btn.tag == 1) {
        [self fadeOutPopUpView:self.menuBtnViewScreen];
    } else {
        [self fadeOutPopUpView:self.tableViewScreen];
    }
}

-(void)popupViewHideTapHandler:(UITapGestureRecognizer *)gestureRecognizer {

    UIView *view = gestureRecognizer.view;
    self.isTableReloadAble = NO;
    self.videoType = kClosePopUpViewCode;
    if (view.tag == 1) {
        [self fadeOutPopUpView:self.menuBtnViewScreen];
    } else {
        [self fadeOutPopUpView:self.tableViewScreen];
    }
}

#pragma mark - FadeIn/FadeOut Methods -
- (void)fadeIn:(UIView *)popUpView {
    popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    popUpView.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        popUpView.alpha = 1;
        popUpView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOutMenuBtnViewScreen
{
    [UIView animateWithDuration:.35 animations:^{
        self.menuBtnViewScreen.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.menuBtnViewScreen.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.menuBtnViewScreen.hidden = YES;
            self.tableViewScreen.hidden = NO;
            [self.tView reloadData];
            [self fadeIn:self.tableViewScreen];
        }
    }];
}

- (IBAction)showMenuBtnAction:(id)sender {
    
    [UIView animateWithDuration:.35 animations:^{
        self.tableViewScreen.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.tableViewScreen.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.tableViewScreen.hidden = YES;
            self.menuBtnViewScreen.hidden = NO;
            [self fadeIn:self.menuBtnViewScreen];
        }
    }];

}

- (void)fadeOut:(UIView *)popUpView
{
    [UIView animateWithDuration:.35 animations:^{
        popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        popUpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}


- (void)fadeOutPopUpView:(UIView *)popUpView
{
    [UIView animateWithDuration:.35 animations:^{
        popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        popUpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            NSDictionary *itemDetails = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:_videoType],@"videoType", nil];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PopUpSubViewNotification"
             object:self userInfo:itemDetails];
        }
    }];
}

#pragma mark - PopUpViewNotification Call Method -
- (void)playSelectedStreamUrl:(NSInteger)section andRow:(NSInteger)row
{
    [UIView animateWithDuration:.35 animations:^{
        self.tableViewScreen.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.tableViewScreen.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            NSDictionary *itemDetails = [NSDictionary new];
            if (self.videoType == 0) {
                itemDetails = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:self.videoType],@"videoType",
                               [NSNumber numberWithInteger:row], @"selectedRow",
                               [NSNumber numberWithInteger:section], @"selectedSection",
                               _surroundViewer, @"surroundViewer",
                               nil];
            } else {
                itemDetails = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInteger:self.videoType],@"videoType",
                        [NSNumber numberWithInteger:row], @"selectedRow",
                        _surroundViewer, @"surroundViewer",
                         nil];
            }
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PopUpSubViewNotification"
             object:self userInfo:itemDetails];
        }
    }];
}

#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.videoType == 0) {
        UserPackage *userPackage = [_surroundViewer.userPackages firstObject];
        return [userPackage.tvCCategoryList count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.videoType == 0) {
        UserPackage *userPackage = [_surroundViewer.userPackages firstObject];
        ChanelCategory *channelCategory = [userPackage.tvCCategoryList objectAtIndex:section];
        return channelCategory.categoryName;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isTableReloadAble) {
        UserPackage *userPackage = [_surroundViewer.userPackages firstObject];
        if (_videoType == 0) {
            ChanelCategory *channelCategory = [userPackage.tvCCategoryList objectAtIndex:section];
            return [channelCategory.channels count];
            
        }else if (_videoType == 1) {
            //return [_surroundViewer.cameras.rows count];
            return [userPackage.userCameraList count];
            
        }else if (_videoType == 2) {
            return [_surroundViewer.friendsCameras.rows count];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///
    static NSString *CellIdentifier = @"CustomTableViewCell";
    CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    UserPackage *userPackage = [_surroundViewer.userPackages firstObject];
    if (self.videoType == 0) {
        ChanelCategory *channelCategory = [userPackage.tvCCategoryList objectAtIndex:indexPath.section];
        Channel * channel = [channelCategory.channels objectAtIndex:indexPath.row];
        cell.iconView.image = [UIImage imageNamed:@"IPTVChannel_icon.png"];
        cell.details.text = [channel valueForKey:@"channelName"];
        
    }else if (self.videoType == 1) {
        Camera *fCam = [userPackage.userCameraList objectAtIndex:indexPath.row];
        cell.iconView.image = [UIImage imageNamed:@"IPTVChannel_icon.png"];
        cell.details.text = fCam.title;
    
    }else if (self.videoType == 2) {
        FriendsCamera *fCam = [_surroundViewer.friendsCameras.rows objectAtIndex:indexPath.row];
        cell.iconView.image = [UIImage imageNamed:@"IPTVChannel_icon.png"];
        cell.details.text = fCam.name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playSelectedStreamUrl:indexPath.section andRow:indexPath.row];
}

@end
