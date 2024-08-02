//
//  FriendsCamera.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "FriendsCamera.h"

@implementation FriendsCamera
- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier emailId:(NSString *)emailId phone:(NSNumber *)phone cameraUrl:(NSString *)cameraUrl andLocation:(Location *)locaition{
    if (self = [super init]) {
        _name = name;
        _identifier = identifier;
        _emailId = emailId;
        _phone = phone;
        _cameraUrl = cameraUrl;
        _location = locaition;
    }
    return self;

}
@end
