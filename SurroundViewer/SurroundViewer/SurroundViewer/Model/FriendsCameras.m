//
//  FriendsCameras.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "FriendsCameras.h"

@implementation FriendsCameras
- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<FriendsCamera> alloc] init];
    }
    return self;
}
@end
