//
//  ReplyUpdater.m
//  SurroundViewer
//
//  Created by makboney on 5/30/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ReplyUpdater.h"

@implementation ReplyUpdater
- (instancetype)initWithOperator:(ReplyOperator *)operatr {
    if (self = [super init]) {
        _operator = operatr;
    }
    return self;
}

#pragma mark - Update Delegates

- (void)update {
    [self onUpdate];
}

- (void)onUpdate {
    [_operator onOperate:UPDATE];
}
@end
