//
//  Cameras.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "Cameras.h"

@implementation Cameras
- (instancetype)init {
    if (self = [super init]) {
        _rows = [[NSMutableArray<Camera> alloc] init];
    }
    return self;
}
@end
