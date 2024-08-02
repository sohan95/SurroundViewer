//
//  Channel.h
//  SurroundViewer
//
//  Created by makboney on 4/24/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dto.h"
@protocol Channel
@end
@interface Channel : JSONModel<Dto>
@property (nonatomic, readwrite) NSString<Optional> *channelName;
@property (nonatomic, readwrite) NSString<Optional> *identifier;
@property (nonatomic, readwrite) NSString<Optional> *url;
@property (nonatomic, readwrite) NSString<Optional> *channelImageUrl;
- (instancetype)initWithName:(NSString *)channelName identifier:(NSString *)identifier streamUrl:(NSString *)url channelImageUrl:(NSString *)channelImageUrl;
@end
