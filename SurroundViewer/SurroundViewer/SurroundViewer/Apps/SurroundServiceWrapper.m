//
//  SurroundServiceWrapper.m
//  SurroundViewer
//
//  Created by makboney on 5/30/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "SurroundServiceWrapper.h"
#import "SurroundOperate.h"
#import "SurroundDefine.h"
@implementation SurroundServiceWrapper
- (instancetype)initWithReplyHandler:(ReplyHandler *)replyHandler; {
    
    self = [super init];
    if (self) {
        _svServiceHandler = [[ServiceHandler alloc] init];
        self.replyHandler = replyHandler;
    }
    return self;
}

#pragma mark - Operator Delegate

- (BOOL)onOperate:(int)ope {
    return [self onOperateMessage:[SurroundOperate messageForOperationCode:ope]];
}

- (BOOL)onOperate:(int)ope andObject:(id)obj {
    return [self onOperateMessage:[SurroundOperate messageForOperationCode:ope andObject:obj]];
}

- (BOOL)onOperateMessage:(id)msg {
    NSLog(@"SurroundServiceWrapper onOperate: msg= %@", [msg description]);
    @synchronized(self) {
        @try {
            NSNotificationCenter *notficationCenter = [NSNotificationCenter defaultCenter];
            [notficationCenter postNotificationName:HANDLE_SEND_MESSAGE object:msg];
        }
        @catch (NSException *exception) {
            return NO;
        }
    }
    NSLog(@"SurroundServiceWrapper onOperate: done.");
    return true;
}
@end
