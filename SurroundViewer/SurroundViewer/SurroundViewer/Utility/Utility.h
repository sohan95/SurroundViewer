//
//  Utility.h
//  SurroundViewer
//
//  Created by makboney on 5/9/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+ (NSDictionary *)getMyCameras;
+ (NSDictionary *)getMyChannels;
+ (NSDictionary *)getMyFriendCams;
//
+ (NSDictionary *)getMyChannels:(NSDictionary *)jsonDataDic;
+ (NSDictionary *)getMyCameras:(NSDictionary *)jsonDataDic;
+ (NSDictionary *)getMyFriendCams:(NSDictionary *)jsonDataDic;
@end
