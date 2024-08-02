//
//  SurroundViewer.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendsCameras.h"
#import "ChannelCategories.h"
#import "UserPackage.h"
#import "Cameras.h"
#import "Conf.h"
#import "User.h"
#import "Dto.h"
@interface SurroundViewer : JSONModel<Dto>
@property (nonatomic, strong) User<Optional> *user;
@property (nonatomic, strong) Conf<Optional> *conf;
@property (nonatomic, strong) NSMutableArray <UserPackage,Optional> *userPackages;
@property (nonatomic, strong) FriendsCameras<Optional> *friendsCameras;
@end
