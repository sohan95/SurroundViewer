//
//  ReplyHandler.h
//  SurroundViewer
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurroundViewer.h"
#import "TableUpdater.h"
#import "Operator.h"
#import "Progress.h"
#import "LoginUpdater.h"
@interface ReplyHandler : NSObject

- (instancetype)initWithSurroundViewer:(SurroundViewer *)surroundViewer operator:(id<Operator>)oprtr progress:(id<Progress>)prgrss loginUpdate:(id<LoginUpdater>)loginUpdater  cameraUpdater:(id<TableUpdater>)cameraUpdater friendsCamUpdater:(id<TableUpdater>)friendsCamUpdater channelsUpdater:(id<TableUpdater>)channelsUpdater andTarget:(id)target;
- (void)handleMessage:(id)msg;
@end
