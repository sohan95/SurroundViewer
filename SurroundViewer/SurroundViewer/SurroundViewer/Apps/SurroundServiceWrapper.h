//
//  SurroundServiceWrapper.h
//  SurroundViewer
//
//  Created by makboney on 5/30/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operator.h"
#import "ServiceHandler.h"
#import "ReplyHandler.h"
@interface SurroundServiceWrapper : NSObject<Operator>{
    ServiceHandler *_svServiceHandler;
}
@property (nonatomic, strong) ReplyHandler *replyHandler;

- (instancetype)initWithReplyHandler:(ReplyHandler *)replyHandler;

@end
