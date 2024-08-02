//
//  Location.m
//  SurroundViewer
//
//  Created by makboney on 5/8/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "Location.h"

@implementation Location
- (instancetype)initWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude andImageMap:(ImageMap *)imageMap {

    if (self = [super init]) {
        _latitude = latitude;
        _longitude = longitude;
        _imageMap = imageMap;
    }
    return self;
}
@end
