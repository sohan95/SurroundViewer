//
//  SurroundOperate.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "SurroundOperate.h"

@implementation SurroundOperate

const int LOAD_LOCAL = 1001;
const int LOGIN_SUCCESS = 1002;
const int LOGIN_FAILED = 1003;

const int LOAD_CONF = 1011;

const int FINI = 1231;

const int INPUT = 1501;

const int LOAD_USER_CONF = 1151;
const int LOAD_USER_CAMERA = 1152;

const int LOAD_USER = 1201;
const int LOAD_USER_PACKAGE = 1202;
const int LOAD_USER_SUCCEEDED = 1208;
const int LOAD_USER_FAILED = 1209;
const int LOAD_USER_CAMERA_SUCCESS = 1210;

const int LOAD_FRIENDS_CAMERA = 3001;
const int LOAD_FRIENDS_CAMERA_ERROR = 3002;

const int LOAD_TV_CHANNELS = 4001;
const int LOAD_TV_CHANNELS_ERROR = 4002;

const int SAVE_CONF = 1811;
const int SAVE_USER_CONF = 1851;
const int SAVE_FRIENDS_CAMERA = 1853;
const int SAVE_SURROUND_VIEWER = 1855;

const int UPDATE = 9001;
const int PROGRESS_CLOSE = 9101;
const int PROGRESS_MSG = 9102;
const int PROGRESS_ERROR = 9103;
const int PROGRESS_TOAST = 9104;
const int PROGRESS_ERR = 9105;


+ (id)messageForOperationCode:(NSUInteger)code{
    NSDictionary *msg = @{@"what":[NSNumber numberWithInteger:code],
                          @"when":[NSDate date]};
    return msg;
}

+ (id)messageForOperationCode:(NSUInteger)code andObject:(id)obj{
    NSDictionary *msg = [[self class] messageForOperationCode:code];
    NSMutableDictionary *newMsgDict = [NSMutableDictionary dictionaryWithDictionary:msg];
    newMsgDict[@"obj"] = obj;
    return newMsgDict;
}
@end
