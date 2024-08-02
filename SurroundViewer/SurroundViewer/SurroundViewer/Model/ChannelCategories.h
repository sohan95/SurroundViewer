//
//  ChannelCategories.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "ChanelCategory.h"
@interface ChannelCategories : JSONModel
@property (nonatomic, strong) NSMutableArray<ChanelCategory,Optional> *rows;
@property (nonatomic, strong) NSMutableArray<ChanelCategory,Optional> *TVCCategoryList;
@end
