//
//  UserPackage.m
//  SurroundViewer
//
//  Created by makboney on 6/12/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "UserPackage.h"

@implementation UserPackage
- (instancetype)init {
    if (self = [super init]) {
        _tvCCategoryList = [[NSMutableArray<ChanelCategory> alloc] init];
        _userCameraList = [[NSMutableArray<Cameras> alloc] init];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"TVCCategoryList": @"tvCCategoryList",
                                                       @"UserCameraList": @"userCameraList"
                                                       }];
}
@end
