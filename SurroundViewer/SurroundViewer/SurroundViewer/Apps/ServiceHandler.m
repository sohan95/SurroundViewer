//
//  ServiceHandler.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ServiceProgress.h"
#import "ServiceHandler.h"
#import "SurroundOperate.h"
#import "ReplyOperator.h"
#import "ServiceProgress.h"
#import "SurroundDefine.h"
#import "ReplyUpdater.h"
#import "NSString+StringUtil.h"
#import "SurroundServiceWrapper.h"
#import "JsonUtil.h"

@implementation ServiceHandler{
    ReplyHandler *_handler;
    NSMutableArray *_msgQueue;
    SurroundServiceWrapper *_service;
}

static ReplyOperator *operator;
static ReplyUpdater *updater;

- (instancetype)init {
    if (self = [super init]) {
        operator = [[ReplyOperator alloc] init];
        updater = [[ReplyUpdater alloc] initWithOperator:operator];
        _surroundViewer = [[SurroundViewer alloc] init];
        _progress = [[ServiceProgress alloc] initWithOperator:operator];
        _http = [[Http alloc] initWithSurroundViewer:_surroundViewer andProgress:_progress];
        _msgQueue = [[NSMutableArray alloc] init];
        _service = [[SurroundServiceWrapper alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMsgNotification:)
                                                     name:HANDLE_SEND_MESSAGE
                                                   object:nil];
    }
    return self;
}

- (void)receiveMsgNotification:(NSNotification *)notification {
    @synchronized (self) {
        if ([[notification name] isEqualToString:HANDLE_SEND_MESSAGE]){
            [self handleMessage:[notification object]];
        }
    }
}

#pragma mark - Operator Delegate

- (BOOL)onOperate:(int)ope {
    id msg = [SurroundOperate messageForOperationCode:ope];
    return [self onOperateMessage:msg];
}

- (BOOL)onOperate:(int)ope andObject:(id)obj {
    return [self onOperate:ope andobject:obj];
}

- (BOOL)onOperate:(int)ope andobject:(id)obj {
    id msg = [SurroundOperate messageForOperationCode:ope andObject:obj];
    return [self onOperateMessage:msg];
}

- (BOOL)onOperateMessage:(id)msg {
    NSLog(@"%@ onOperateMessage %@",NSStringFromClass([self class]),msg);
    NSUInteger op = [msg[@"what"] integerValue];
    BOOL ret = YES;
    do {
        if (op == LOAD_LOCAL) {
            [_progress msg:LOAD_MSG_LOCAL];
            [self onOperate:LOAD_CONF];
            BOOL result = [self onOperate:LOAD_USER_CONF];
            if(result) {
                [operator onOperate:LOAD_USER_SUCCEEDED];
                [_msgQueue addObject:[NSNumber numberWithInt:LOAD_USER_PACKAGE]];
                [_msgQueue addObject:[NSNumber numberWithInt:LOAD_FRIENDS_CAMERA]];
            }else {
                [operator onOperate:LOAD_USER_FAILED];
            }
        }else if(op == LOAD_CONF) {
            _surroundViewer.conf = [JsonUtil loadObject:NSStringFromClass([Conf class]) withFile:@"conf"];
            [operator onOperate:msg andobject:_surroundViewer.conf];
        }else if(op == LOAD_USER_CONF) {
            _surroundViewer.user = [[User alloc] init];
            __block BOOL OK = YES;
            @try {
                if([_surroundViewer.conf.userName isEmptyString] || [_surroundViewer.conf.password isEmptyString]) {
                    [_progress close];
                    ret = NO;
                    break;
                }
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                [_http authenticateUser:^(id object, NSError *error){
                    if (error) {
                        OK = NO;
                        [_progress toast:LOAD_MSG_USER_CONF];
                        _surroundViewer.user.UserName = @"";
                        _surroundViewer.user.firstName = @"";
                    }else{
                        User *user = [[User alloc] initWithDictionary:object error:&error];
                        if (user) {
                            _surroundViewer.user = [user copy];
                        }else{
                            OK = NO;
                        }
                    }
                    dispatch_semaphore_signal(sema);
                }];
                while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW)) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
                }
                if (!OK) {
                    ret = NO;
                    break;
                }
            }
            @finally {
                [self onOperate:SAVE_USER_CONF andobject:_surroundViewer.user];
                if(OK){
                    [operator onOperate:msg andobject:_surroundViewer.user];
                }
            }
        }else if (op == LOAD_USER_PACKAGE){
            _surroundViewer.user.sessionToken = @"surroundapps_2016";
            _surroundViewer.conf.appId = @1;
            [_http getUserPackageByUserIDForMobileAppWithCompletionBlock:^(id object, NSError *error){
                if (error) {
                    
                }else {
                    NSArray *userPackageList = [object valueForKey:@"userPackageList"];
                    if (userPackageList) {
                        _surroundViewer.userPackages = (NSMutableArray<UserPackage> *)[UserPackage  arrayOfModelsFromDictionaries:userPackageList error:nil];
                        [self onOperate:SAVE_SURROUND_VIEWER andObject:_surroundViewer.userPackages];
                    }
                }
                [operator onOperate:msg andobject:_surroundViewer.userPackages];
            }];
        }else if (op == LOAD_FRIENDS_CAMERA){
            _surroundViewer.friendsCameras = [[FriendsCameras alloc] init];
            __block BOOL OK;
            [_http getFriendsCameras:^(id object, NSError *error){
                if (error) {
                    OK = NO;
                    [_progress toast:LOAD_MSG_FRIENDS_CAMERA_ERROR];
                }else{
                    _surroundViewer.friendsCameras = [object copy];
                    [JsonUtil saveObject:_surroundViewer.friendsCameras withFile:NSStringFromClass([FriendsCameras class])];
                }
                [operator onOperate:msg andobject:_surroundViewer.friendsCameras];
            }];
        }else if(op == SAVE_FRIENDS_CAMERA) {
            FriendsCameras *friendsCameras = (FriendsCameras *) [msg valueForKey:@"obj"];
            [_surroundViewer.friendsCameras.rows removeAllObjects];
            [_surroundViewer.friendsCameras.rows addObjectsFromArray:friendsCameras.rows];
            [JsonUtil saveObject:_surroundViewer.friendsCameras withFile:NSStringFromClass([FriendsCameras class])];
        }else if(op == SAVE_CONF) {
            // Configuration
            Conf *conf = (Conf*) [msg valueForKey:@"obj"];
            _surroundViewer.conf = conf;
            [JsonUtil saveObject:_surroundViewer.conf withFile:@"conf"];
        }else if(op == SAVE_SURROUND_VIEWER) {
            // saving SurroundViewer
            _surroundViewer.userPackages = (NSMutableArray<UserPackage>*) [msg valueForKey:@"obj"];
            [JsonUtil saveObject:_surroundViewer withFile:@"surroundviewer"];
        }
    }while (NO);
    if(_msgQueue.count !=0 && op >= LOAD_LOCAL) {
        int nextOpe = [[self poll:_msgQueue ] intValue];
        NSLog(@"%@ msgQueue:ope= %d",NSStringFromClass([self class]),nextOpe);
        [_service onOperateMessage:[SurroundOperate messageForOperationCode:nextOpe]];
    }
    return ret;
}

- (id)poll:(NSMutableArray *)queue {
    id headObject = [queue objectAtIndex:0];
    if (headObject != nil) {
        [queue removeObjectAtIndex:0];
    }
    return headObject;
}

- (void)handleMessage:(id)msg {
    [self onOperateMessage:msg];
    [updater update];
}

- (BOOL)onOperate:(id)msg operation:(NSUInteger)ope {
    id req = [SurroundOperate messageForOperationCode:ope andObject:msg];
    return [self onOperateMessage:req];
}
@end
