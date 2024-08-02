//
//  Conf.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 5/29/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "JSONModel.h"
#import "Dto.h"
@interface Conf : JSONModel<Dto>
@property (nonatomic, readwrite) NSString<Optional> *userName;
@property (nonatomic, readwrite) NSString<Optional> *password;
@property (nonatomic, readwrite) NSString<Optional> *fileServerAddr;
@property (nonatomic, readwrite) NSNumber<Optional> *platformId;
@property (nonatomic, readwrite) NSNumber<Optional> *appId;
@property (nonatomic, readwrite) NSNumber<Optional> *loginFirstTime;
@end
