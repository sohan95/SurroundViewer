//
//  SurroundOperate.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurroundOperate : NSObject
extern int const LOAD_LOCAL;
extern int const LOGIN_SUCCESS;
extern int const LOGIN_FAILED;

extern int const LOAD_CONF;

extern int const FINI;

extern int constINPUT;

extern int const LOAD_USER_CONF;
extern int const LOAD_USER_CAMERA;
extern int const LOAD_USER_PACKAGE;
extern int const LOAD_USER;
extern int const LOAD_USER_SUCCEEDED;
extern int const LOAD_USER_FAILED;
extern int const LOAD_USER_CAMERA_SUCCESS;

extern int const LOAD_FRIENDS_CAMERA;
extern int const LOAD_FRIENDS_CAMERA_ERROR;

extern int const SAVE_CONF;
extern int const SAVE_USER_CONF;
extern int const SAVE_FRIENDS_CAMERA;
extern int const SAVE_SURROUND_VIEWER;
extern int const UPDATE;
extern int const PROGRESS_CLOSE;
extern int const PROGRESS_MSG;
extern int const PROGRESS_ERROR;
extern int const PROGRESS_TOAST;
extern int const PROGRESS_ERR;

+ (id)messageForOperationCode:(NSUInteger)code;
+ (id)messageForOperationCode:(NSUInteger)code andObject:(id)obj;
@end
