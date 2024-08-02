//
//  Cameras.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Camera.h"
@protocol Cameras
@end
@interface Cameras : JSONModel
@property (nonatomic, strong) NSMutableArray<Camera,Optional> *rows;
@end
