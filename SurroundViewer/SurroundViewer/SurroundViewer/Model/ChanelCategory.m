//
//  ChanelCategory.m
//  SurroundViewer
//
//  Created by makboney on 5/8/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ChanelCategory.h"

@implementation ChanelCategory
- (instancetype)init {

    if (self = [super init]) {
        _channels = [[NSMutableArray<Channel> alloc] init];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)categoryName identifier:(NSString *)identifier categoryImageUrl:(NSString *)categoryImageUrl andChannel:( NSMutableArray<Channel *> *)channels {
    if (self = [super init]) {
        _categoryName = categoryName;
        _identifier = identifier;
        _categoryImageUrl = categoryImageUrl;
        _channels = [channels mutableCopy];
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"CategoryName": @"categoryName",
                                                       @"identifier": @"Id",
                                                       @"TVChannelList": @"channels"
                                                       }];
}

@end
