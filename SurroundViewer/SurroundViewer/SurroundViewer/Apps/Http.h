//
//  Http.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

typedef void (^SABooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^SAArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^SAObjectResultBlock)(id object, NSError *error);

#import <Foundation/Foundation.h>
#import "SurroundViewer.h"
#import "Progress.h"
@interface Http : NSObject

@property (nonatomic, retain) NSURLSessionConfiguration *defaultConfiguration;
@property (nonatomic, retain) NSURLSession *defaultSession;
- (instancetype)initWithSurroundViewer:(SurroundViewer *)surroundViewer andProgress:(id<Progress>)progress;
- (instancetype)initWithProgress:(id<Progress>)progress;
- (void)getFriendsCameras:(SAObjectResultBlock)block;
- (void)getUserPackageByUserIDForMobileAppWithCompletionBlock:(SAObjectResultBlock)block;
- (void)authenticateUser:(SAObjectResultBlock)block;
@end
