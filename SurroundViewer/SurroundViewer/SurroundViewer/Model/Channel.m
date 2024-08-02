//
//  Channel.m
//  SurroundViewer
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "Channel.h"

@implementation Channel
- (instancetype)initWithName:(NSString *)channelName identifier:(NSString *)identifier streamUrl:(NSString *)url channelImageUrl:(NSString *)channelImageUrl {

    if (self = [super init]) {
        _channelName = channelName;
        _identifier = identifier;
        _url = url;
        _channelImageUrl = channelImageUrl;
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"Name": @"channelName",
                                                       @"identifier": @"Id",
                                                       @"URL": @"url",
                                                       @"Logo": @"channelImageUrl"
                                                       }];
}
@end
