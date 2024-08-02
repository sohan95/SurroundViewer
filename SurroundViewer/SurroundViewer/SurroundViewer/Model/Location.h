//
//  Location.h
//  SurroundViewer
//
//  Created by makboney on 5/8/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageMap.h"
#import "Dto.h"
@interface Location : JSONModel<Dto>
@property (nonatomic, retain) NSNumber<Optional> *latitude;
@property (nonatomic, retain) NSNumber<Optional> *longitude;
@property (nonatomic, retain) ImageMap<Optional> *imageMap;
- (instancetype)initWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude andImageMap:(ImageMap *)imageMap;
@end
