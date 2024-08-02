//
//  UserPackage.h
//  SurroundViewer
//
//  Created by makboney on 6/12/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "ChanelCategory.h"
#import "Cameras.h"
@protocol UserPackage
@end
@interface UserPackage : JSONModel
@property (nonatomic, strong) NSString<Optional> *PackageName;
@property (nonatomic, strong) NSMutableArray<ChanelCategory,Optional> *tvCCategoryList;
@property (nonatomic, strong) NSMutableArray<Camera,Optional> *userCameraList;
@end
