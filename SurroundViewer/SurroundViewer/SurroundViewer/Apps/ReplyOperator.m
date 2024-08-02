//
//  ReplyOperator.m
//  SurorundApps
//
//  Created by makboney on 2/3/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ReplyOperator.h"
#import "SurroundOperate.h"
#import "SurroundDefine.h"
@implementation ReplyOperator

- (BOOL)onOperate:(id)msg andobject:(id)object {
    return [self onOperateMessage:[SurroundOperate messageForOperationCode:[msg[@"what"] intValue] andObject:object]];
}

#pragma mark - Operator Delegates

- (BOOL)onOperateMessage:(id)msg {
    @synchronized(self) {
        NSLog(@"ReplyOperator onOperate: msg= %@",msg);
        NSNotificationCenter *notficationCenter = [NSNotificationCenter defaultCenter];
        [notficationCenter postNotificationName:HANDLE_REPLY_OPERATOR object:msg];
        return YES;
    }
}

- (BOOL)onOperate:(int)ope {
    return [self onOperateMessage:[SurroundOperate messageForOperationCode:ope]];
}

- (BOOL)onOperate:(int)ope andObject:(id)obj {
    return [self onOperateMessage:[SurroundOperate messageForOperationCode:ope andObject:obj]];
}
@end
