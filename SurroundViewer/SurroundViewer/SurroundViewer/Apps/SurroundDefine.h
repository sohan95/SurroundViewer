//
//  SurroundDefine.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurroundDefine : NSObject

#define BASEIUSERURL @"http://54.200.112.228/GroupDirectTestServices"
#define BASEIUSERURL2 @"http://services.biocomalert.com/Users.svc/"
#define BASEIUSERURL3 @"http://services.biocomalert.com/Companies.svc/"


#define kAppId @"9"

#define kRequestTimeOut 40.0f

#define kRemoteErrorDomain @"Remote"
#define kRemoteErrorStatusCode 201

#define kRemoteServerErrorMessag @"No response from server"

#define kErrorStatusKey @"result"

#define kInternalErrorStatusCode 301
#define kInternalErrorDomain @"Internal"
#define kClosePopUpViewCode 999
//---RGB value define---//
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

extern NSString * const BAD_REQUEST;
extern NSString * const UNAUTHORIZED;
extern NSString * const UNKNOWN;

extern NSString * const HANDLE_REPLY_OPERATOR;
extern NSString * const HANDLE_SEND_MESSAGE;

extern NSString * const LOAD_MSG_LOCAL;
extern NSString * const LOAD_MSG_CAMERA;
extern NSString * const LOAD_MSG_CAMERA_ERROR;
extern NSString * const LOAD_MSG_FRIENDS_CAMERA;
extern NSString * const LOAD_MSG_FRIENDS_CAMERA_ERROR;
extern NSString * const LOAD_MSG_TV_CHANNELS_CATEGORIES;
extern NSString * const LOAD_MSG_TV_CHANNELS_CATEGORIES_ERROR;
extern NSString * const LOAD_MSG_USER_CONF;
extern NSString * const LOAD_MSG_USER_CONF_ERROR;

extern NSString * const URL_REQUEST_BODY;
extern NSString * const URL_SCHEMA;
extern NSString * const URL_BASE_PATH;
extern NSString * const URL_BASE_PATH_2;
extern NSString * const URL_GET_USER_PACKAGE;
extern NSString * const URL_GET_ALL_CAMERAS;
extern NSString * const URL_GET_USER_LOGIN;
@end
