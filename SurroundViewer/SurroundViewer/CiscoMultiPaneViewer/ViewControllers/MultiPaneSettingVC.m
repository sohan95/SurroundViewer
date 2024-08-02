//
//  MultiPaneSettingVC.m
//  cisco_demo
//
//  Created by einfochips on 2/23/16.
//  Copyright © 2016 einfochips. All rights reserved.
//

#import "MultiPaneSettingVC.h"
#import "MultiPaneViewController.h"
#import "AppDelegate.h"

#import "Constant.h"
#import "StreamerConfiguration.h"

@interface MultiPaneSettingVC ()
{
    StreamerConfiguration *streamerConfig;
    
    NSInteger selectedRow;
    
    NSArray *wowzaStandradResolutions;
    
    UIPopoverController *popoverController;
    IBOutlet UIView *pickerView;
    IBOutlet UIPickerView *resolutionPickerView;
    IBOutlet UIToolbar *pickerToolbar;
}

@property (strong, nonatomic) IBOutlet UIView *paneViwerSettingContainer;
@property (strong, nonatomic) IBOutlet UIView *resolutionSettingContainer;
@property (strong, nonatomic) IBOutlet UIButton *selectResolution;

@property (strong, nonatomic) IBOutlet UISwitch *autoManualResolutionOnOff;

@property (strong, nonatomic) IBOutlet UIButton *twoXone;
@property (strong, nonatomic) IBOutlet UIButton *oneXtwo;
@property (strong, nonatomic) IBOutlet UIButton *oneXone;
@property (strong, nonatomic) IBOutlet UIButton *twoXtwo;

@end

@implementation MultiPaneSettingVC

@synthesize oneXone, oneXtwo, twoXone, twoXtwo;

- (void)viewDidLoad {
	
	[super viewDidLoad];
    
    streamerConfig = [StreamerConfiguration sharedInstance];
    
    [self setUnselectedButton];
    
    if ([streamerConfig isLayoutStyleSelected:kLayoutStyle1x1]) {
        [oneXone setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@selected.png",kLayoutStyle1x1]] forState:UIControlStateNormal];
        
    } else if ([streamerConfig isLayoutStyleSelected:kLayoutStyle2x1]) {
        [twoXone setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@selected.png",kLayoutStyle2x1]] forState:UIControlStateNormal];
        
    } else if ([streamerConfig isLayoutStyleSelected:kLayoutStyle1x2]) {
        [oneXtwo setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@selected.png",kLayoutStyle1x2]] forState:UIControlStateNormal];
        
    } else if ([streamerConfig isLayoutStyleSelected:kLayoutStyle2x2]) {
        [twoXtwo setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@selected.png",kLayoutStyle2x2]] forState:UIControlStateNormal];
    }
    
    wowzaStandradResolutions = @[@"720p", @"360p", @"480p", @"240p", @"220p", @"160p"];
    
    BOOL isAutomaivModeOn = [streamerConfig isAutomaticModeEnabledForTranscoding];
    [self.selectResolution setHidden:isAutomaivModeOn];
    [self.autoManualResolutionOnOff setOn:isAutomaivModeOn];
    
    [self.paneViwerSettingContainer setHidden:NO];
    [self.resolutionSettingContainer setHidden:YES];
    
    NSString *selectedManualResolution = [streamerConfig getResolutionForManualTrancoder];
    if (selectedManualResolution == NULL) {
        [self.selectResolution setTitle:@"Select Resolution" forState:UIControlStateNormal];
    }
    else {
        [self.selectResolution setTitle:[NSString stringWithFormat:@"Resolution: %@",selectedManualResolution] forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self restrictRotation:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - User Define Methods

- (void)setUnselectedButton {
    [oneXone setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@unselected.png",kLayoutStyle1x1]] forState:UIControlStateNormal];
    [oneXtwo setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@unselected.png",kLayoutStyle1x2]] forState:UIControlStateNormal];
    [twoXone setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@unselected.png",kLayoutStyle2x1]] forState:UIControlStateNormal];
    [twoXtwo setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@unselected.png",kLayoutStyle2x2]] forState:UIControlStateNormal];
}

#pragma mark - Button Actions

- (IBAction)changePlayerSetting:(UISegmentedControl *)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        // Select Pane vew
        [self.paneViwerSettingContainer setHidden:NO];
        [self.resolutionSettingContainer setHidden:YES];
    }
    else {
        [self.resolutionSettingContainer setHidden:NO];
        [self.paneViwerSettingContainer setHidden:YES];
    }
}

- (IBAction)changeAutoManualMode:(UISwitch *)sender {
    NSInteger selectedSegment = sender.on;
    
    if (selectedSegment == 0) {
        // Auto Resolution OFF
        [self.selectResolution setHidden:NO];
        
//        NSString *userSelection = [streamerConfig getResolutionForManualTrancoder];
//        if (userSelection == nil || userSelection.length == 0) {
//            self.navigationController.navigationItem.hidesBackButton = YES;
//        }
    }
    else{
        // Auto Resolution ON
        [self.selectResolution setHidden:YES];
    }
    
    [streamerConfig setAutoManualModeForTranscoder:selectedSegment];
}

- (IBAction)chooseResolutionSelectionMode:(id)sender {

    // Open Picker for selecting xAddr
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self showPickerView:sender];
    }
    else
    {
        pickerView.hidden= false;
    }
    // Reload picker data
    [resolutionPickerView reloadAllComponents];
}

- (IBAction)oneXone:(id)sender {
	
    [self setUnselectedButton];
    
    NSString *imgName = [NSString stringWithFormat:@"%@selected.png",kLayoutStyle1x1];
	[oneXone setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    [streamerConfig setSelectedLayoutStyle:kLayoutStyle1x1];
}

- (IBAction)oneXtwo:(id)sender {
	
	[self setUnselectedButton];
    NSString *imgName = [NSString stringWithFormat:@"%@selected.png",kLayoutStyle1x2];
    [oneXtwo setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    [streamerConfig setSelectedLayoutStyle:kLayoutStyle1x2];

}

- (IBAction)twoXtwo:(id)sender {
	
	[self setUnselectedButton];
    NSString *imgName = [NSString stringWithFormat:@"%@selected.png",kLayoutStyle2x2];
    [twoXtwo setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    [streamerConfig setSelectedLayoutStyle:kLayoutStyle2x2];
}

- (IBAction)twoXone:(id)sender {
	
	[self setUnselectedButton];
    NSString *imgName = [NSString stringWithFormat:@"%@selected.png",kLayoutStyle2x1];
    [twoXone setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    [streamerConfig setSelectedLayoutStyle:kLayoutStyle2x1];
}

#pragma -mark PickerView

- (void)showPickerView:(id)sender
{
    UIView *masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 260)];
    
    // Create Toolbar for the Picker
    pickerToolbar = [self createPickerToolbarWithTitle:@"Select"];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    [masterView addSubview:pickerToolbar];
    
    // Create PickerView
    CGRect pickerFrame = CGRectMake(0,40, 300, 216);
    resolutionPickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    [resolutionPickerView setDataSource: self];
    [resolutionPickerView setDelegate: self];
    resolutionPickerView.tag=1;
    [resolutionPickerView selectRow:0 inComponent:0 animated:NO];
    [resolutionPickerView setShowsSelectionIndicator:YES];
    
    // Add PickerView to MasterView
    [masterView addSubview:resolutionPickerView];
    
    // Create View Controller and assign Picker view
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    viewController.view = masterView;
    viewController.preferredContentSize = viewController.view.frame.size;
    
    // Open PopoverController
    popoverController =[[UIPopoverController alloc] initWithContentViewController:viewController];
    UIButton *button = (UIButton *)sender;
    [popoverController presentPopoverFromRect:button.bounds
                                       inView:button
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

// Create custom Toolbar
- (UIToolbar *)createPickerToolbarWithTitle:(NSString *)title
{
    CGRect frame = CGRectMake(0, 0, 300, 44);
    UIToolbar *pickerToolbar1 = [[UIToolbar alloc] initWithFrame:frame];
    pickerToolbar1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pickerToolbar1.barStyle = UIBarStyleBlackOpaque;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *cancelBtn = [self createButtonWithType:UIBarButtonSystemItemCancel target:self action:@selector(touchesActionPickerCancel:)];
    [barItems addObject:cancelBtn];
    UIBarButtonItem *flexSpace = [self createButtonWithType:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [barItems addObject:flexSpace];
    
    if (title)
    {
        UIBarButtonItem *labelButton = [self createToolbarLabelWithTitle:title];
        [barItems addObject:labelButton];
        [barItems addObject:flexSpace];
    }
    
    UIBarButtonItem *doneButton = [self createButtonWithType:UIBarButtonSystemItemDone target:self action:@selector(touchesActionPickerDone:)];
    [barItems addObject:doneButton];
    [pickerToolbar1 setItems:barItems animated:YES];
    return pickerToolbar1;
}

// Create custom Toolbar label
- (UIBarButtonItem *)createToolbarLabelWithTitle:(NSString *)aTitle
{
    UILabel *toolBarItemlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180,30)];
    
    [toolBarItemlabel setTextAlignment:NSTextAlignmentCenter];
    [toolBarItemlabel setTextColor:[UIColor whiteColor]];
    [toolBarItemlabel setFont:[UIFont boldSystemFontOfSize:16]];
    [toolBarItemlabel setBackgroundColor:[UIColor clearColor]];
    toolBarItemlabel.text = aTitle;
    
    UIBarButtonItem *buttonLabel = [[UIBarButtonItem alloc]initWithCustomView:toolBarItemlabel];
    return buttonLabel;
}

// Create Bar button
- (UIBarButtonItem *)createButtonWithType:(UIBarButtonSystemItem)type target:(id)target action:(SEL)buttonAction
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:type target:target action:buttonAction];
}

// On Done button touched Hide pickerView and set Selected value on Button
- (IBAction)touchesActionPickerDone:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (popoverController && popoverController.popoverVisible)
            [popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        pickerView.hidden= true;
    }
    
    NSString *selectedResolution = [wowzaStandradResolutions objectAtIndex:[resolutionPickerView selectedRowInComponent:0]];
    
//    if (selectedResolution.length > 0) {
//        self.navigationController.navigationItem.hidesBackButton = NO;
//    }
    [streamerConfig setResolutionForManualTrancoder:selectedResolution];
    [self.selectResolution setTitle:[NSString stringWithFormat:@"Resolution: %@",selectedResolution] forState:UIControlStateNormal];
}

// On Cancel button touched hide pickerview
- (IBAction)touchesActionPickerCancel:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (popoverController && popoverController.popoverVisible)
            [popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        pickerView.hidden= true;
    }
    [resolutionPickerView selectRow:0 inComponent:0 animated:YES];
}

#pragma -mark --PickerView Delegats
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [wowzaStandradResolutions count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [wowzaStandradResolutions objectAtIndex:row];
}
- (UIView *)pickerView:(UIPickerView *)pickerView1 viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 27)];
    lable.font = [UIFont systemFontOfSize:16];
    lable.text = [self pickerView:pickerView1 titleForRow:row forComponent:component];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor blackColor];
    
    return lable;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedRow = row;
}

#pragma mark - Restriction Rotation
-(void) restrictRotation:(BOOL)restriction
{
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.restrictRotation = restriction;
}

@end
