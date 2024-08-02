//
//  ServiceHandler.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurroundViewer.h"
#import "Updater.h"
#import "Progress.h"
#import "Http.h"
#import "ReplyHandler.h"

@interface ServiceHandler : NSObject<Operator> {
    SurroundViewer *_surroundViewer;
    Http *_http;
    id<Progress> _progress;
}
- (BOOL)onOperate:(id)msg operation:(NSUInteger)ope;
- (void)handleMessage:(id)msg;
@end
