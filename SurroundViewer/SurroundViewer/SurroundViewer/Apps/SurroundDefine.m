//
//  SurroundDefine.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "SurroundDefine.h"

@implementation SurroundDefine
NSString * const BAD_REQUEST = @"Bad Request";
NSString * const UNAUTHORIZED = @"Unauthorised Access";
NSString * const UNKNOWN = @"Http error";

NSString * const LOAD_CAMERA_ERROR_MSG = @"Problem in loading camera";

NSString * const HANDLE_REPLY_OPERATOR = @"com.surroundapps.surroundview.replymsg";
NSString * const HANDLE_SEND_MESSAGE = @"com.surroundapps.surroundview.sendmsg";

NSString * const LOAD_MSG_LOCAL = @"Loading...";
NSString * const LOAD_MSG_CAMERA = @"Loading camera...";
NSString * const LOAD_MSG_CAMERA_ERROR = @"Error in loading camera";
NSString * const LOAD_MSG_FRIENDS_CAMERA = @"Loading friends camera...";
NSString * const LOAD_MSG_FRIENDS_CAMERA_ERROR = @"Error in loading camera";
NSString * const LOAD_MSG_TV_CHANNELS_CATEGORIES = @"Loading tv channels...";
NSString * const LOAD_MSG_TV_CHANNELS_CATEGORIES_ERROR = @"Error in loading tv channels";
NSString * const LOAD_MSG_USER_CONF =  @"Authenticating...";
NSString * const LOAD_MSG_USER_CONF_ERROR = @"Error in authentication";

NSString * const URL_REQUEST_BODY = @"sessionToken=$sessionToken$&ID=$ID$";
NSString * const URL_SCHEMA = @"http://";
NSString * const URL_BASE_PATH_2 = @"/SVUserServices/SignupService.svc/";
NSString * const URL_BASE_PATH = @"/SurroundViewerServices/Service1.svc/";
NSString * const URL_GET_USER_PACKAGE = @"GetUserPackageByUserIDForMobileApp";
NSString * const URL_GET_USER_LOGIN = @"login";
NSString * const URL_GET_ALL_CAMERAS = @"GetAllCameras";
@end
