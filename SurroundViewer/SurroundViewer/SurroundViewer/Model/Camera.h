//
//  Camera.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Dto.h"
@protocol Camera
@end
@interface Camera : JSONModel<Dto>
@property (nonatomic, retain) NSString<Optional> *title;
@property (nonatomic, retain) NSNumber<Optional> *identifier;
@property (nonatomic, retain) NSString<Optional> *ipAddress;
@property (nonatomic, retain) NSString<Optional> *userName;
@property (nonatomic, retain) NSString<Optional> *password;
@property (nonatomic, retain) Location<Optional> *location;
@property (nonatomic, retain) NSNumber<Optional> *panelTag;
- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier ipAddress:(NSString *)ipAddress userName:(NSString *)userName passWord:(NSString *)password andLocation:(Location *)locaition;
@end
