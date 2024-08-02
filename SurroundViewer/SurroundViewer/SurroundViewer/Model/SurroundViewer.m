//
//  SurroundViewer.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "SurroundViewer.h"

@implementation SurroundViewer
- (instancetype)init {
    if (self = [super init]) {
        _userPackages = [[NSMutableArray<UserPackage> alloc] init];
        _friendsCameras = [[FriendsCameras alloc] init];
    }
    return self;
}
@end
