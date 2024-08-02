//
//  Camera.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "Camera.h"

@implementation Camera
- (instancetype)initWithTitle:(NSString *)title identifier:(NSNumber *)identifier ipAddress:(NSString *)ipAddress userName:(NSString *)userName passWord:(NSString *)password andLocation:(Location *)location {
    if (self = [super init]) {
        _title = title;
        _identifier = identifier;
        _ipAddress = ipAddress;
        _userName = userName;
        _password = password;
        _location = location;
    }
    return self;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"CamerUserName": @"userName",
                                                       @"CameraIP": @"ipAddress",
                                                       @"CameraName":@"title",
                                                       @"CameraPassword":@"password",
                                                       @"Id":@"identifier"
                                                       }];
}

@end
