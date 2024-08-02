//
//  ChanelCategory.h
//  SurroundViewer
//
//  Created by makboney on 5/8/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
#import "Dto.h"
@protocol ChanelCategory
@end
@interface ChanelCategory : JSONModel<Dto>
@property (nonatomic, readwrite) NSString<Optional> *categoryName;
@property (nonatomic, readwrite) NSString<Optional> *identifier;
@property (nonatomic, readwrite) NSString<Optional> *categoryImageUrl;
@property (nonatomic, readwrite) NSMutableArray<Channel,Optional> *channels;
- (instancetype)initWithName:(NSString *)categoryName identifier:(NSString *)identifier categoryImageUrl:(NSString *)categoryImageUrl andChannel:( NSMutableArray<Channel *> *)channels;

@end
