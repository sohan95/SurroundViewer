//
//  FriendsCameras.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "FriendsCamera.h"
@interface FriendsCameras : JSONModel
@property (nonatomic, strong) NSMutableArray<FriendsCamera,Optional> *rows;
@end
