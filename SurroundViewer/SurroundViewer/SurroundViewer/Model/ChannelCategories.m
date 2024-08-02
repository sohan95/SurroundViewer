//
//  ChannelCategories.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ChannelCategories.h"

@implementation ChannelCategories
- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<ChanelCategory> alloc] init];
        _TVCCategoryList = [[NSMutableArray<ChanelCategory> alloc] init];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"TVCCategoryList": @"rows"}];
}
@end
