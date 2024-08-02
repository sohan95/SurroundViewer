//
//  ReplyUpdater.h
//  SurroundViewer
//
//  Created by makboney on 5/30/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurroundOperate.h"
#import "ReplyOperator.h"
#import "Updater.h"

@interface ReplyUpdater : NSObject<Updater>{
    ReplyOperator *_operator;
}
- (instancetype)initWithOperator:(ReplyOperator *)operatr;
@end
