//
//  ImageMap.h
//  SurroundViewer
//
//  Created by makboney on 5/8/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"
@interface ImageMap : JSONModel<Dto>
@property (nonatomic, retain) NSString<Optional> *imageMapUrl;
@property (nonatomic, retain) NSArray *cameraPostions;
@end
