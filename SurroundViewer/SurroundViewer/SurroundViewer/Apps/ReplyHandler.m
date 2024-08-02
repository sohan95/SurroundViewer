//
//  ReplyHandler.m
//  SurroundViewer
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "SurroundOperate.h"
#import "SurroundDefine.h"
#import "ReplyHandler.h"
#import "MultiPaneViewController.h"
@interface ReplyHandler () {
    id _target;
    SurroundViewer *_surroundViewer;
    id <Operator> _opertor;
    id <Progress> _progress;
    id <TableUpdater> _cameraUpdater;
    id <TableUpdater> _friendsCamUpdater;
    id <TableUpdater> _channelsUpdater;
    id <LoginUpdater> _loginUpdater;
}
@end

@implementation ReplyHandler

- (instancetype)initWithSurroundViewer:(SurroundViewer *)surroundViewer operator:(id<Operator>)oprtr progress:(id<Progress>)prgrss loginUpdate:(id<LoginUpdater>)loginUpdater  cameraUpdater:(id<TableUpdater>)cameraUpdater friendsCamUpdater:(id<TableUpdater>)friendsCamUpdater channelsUpdater:(id<TableUpdater>)channelsUpdater andTarget:(id)target{
    if (self = [super init]) {
        _target = target;
        _surroundViewer = surroundViewer;
        _opertor = oprtr;
        _progress = prgrss;
        _cameraUpdater = cameraUpdater;
        _friendsCamUpdater = friendsCamUpdater;
        _channelsUpdater = channelsUpdater;
        _loginUpdater = loginUpdater;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveReplyNotification:)
                                                     name:HANDLE_REPLY_OPERATOR
                                                   object:nil];
    }
    return self;
}

- (void)receiveReplyNotification:(NSNotification *)notification{
    if ([[notification name] isEqualToString:HANDLE_REPLY_OPERATOR]){
        [self handleMessage:[notification object]];
        NSLog(@"%@",[notification object]);
    }
}

- (void)handleMessage:(id)msg {
    NSLog(@"ReplyHandler onOperate: msg= %@", [msg description]);
    NSUInteger ope = [msg[@"what"] integerValue];
    if(ope == UPDATE) {
        
    }else if(ope == PROGRESS_CLOSE) {
        [_progress close];
    }else if(ope == PROGRESS_MSG) {
        NSString *str = msg[@"obj"];
        [_progress msg:str];
    }else if(ope == PROGRESS_ERROR) {
        NSString *str = msg[@"obj"];
        [_progress error:str];
    }else if(ope == PROGRESS_TOAST) {
        NSString *str = msg[@"obj"];
        [_progress toast:str];
    }else if(ope == PROGRESS_ERR) {
        NSString *str = msg[@"obj"];
        [_progress err:str];
    }else if(ope == PROGRESS_CLOSE) {
        [_progress close];
    }else if(ope == PROGRESS_MSG) {
        NSString *str = msg[@"obj"];
        [_progress msg:str];
    }else if(ope == PROGRESS_ERROR) {
        NSString *str = msg[@"obj"];
        [_progress error:str];
    }else if(ope == PROGRESS_TOAST) {
        NSString *str = msg[@"obj"];
        [_progress toast:str];
    }else if(ope == PROGRESS_ERR) {
        NSString *str = msg[@"obj"];
        [_progress err:str];
    }else if(ope == LOAD_LOCAL) {
        
    }else if(ope == LOAD_CONF) {
        Conf *conf = (Conf*) msg[@"obj"];
        _surroundViewer.conf = conf;
    }else if(ope == LOAD_FRIENDS_CAMERA) {
        FriendsCameras *friendsCameras = (FriendsCameras *) msg[@"obj"];
        [_surroundViewer.friendsCameras.rows removeAllObjects];
        [_surroundViewer.friendsCameras.rows addObjectsFromArray:friendsCameras.rows];
    }else if(ope == LOAD_USER_CONF) {
        User *user = (User*) msg[@"obj"];
        _surroundViewer.user = user;
    }else if(ope == LOAD_USER_PACKAGE) {
        _surroundViewer.userPackages = (NSMutableArray<UserPackage>*) [msg valueForKey:@"obj"];
        [_target performSelector:@selector(update)];
    }else if (ope == LOAD_USER_FAILED){
        [_loginUpdater loginSuccess:NO];
    }else if (ope == LOAD_USER_SUCCEEDED){
        [_loginUpdater loginSuccess:YES];
    }
}

@end
