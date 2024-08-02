//
//  FriendsCamera.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Dto.h"
@protocol FriendsCamera
@end
@interface FriendsCamera : JSONModel<Dto>

@property (nonatomic, readwrite) NSString<Optional> *name;
@property (nonatomic, readwrite) NSString<Optional> *identifier;
@property (nonatomic, readwrite) NSString<Optional> *emailId;
@property (nonatomic, readwrite) NSNumber<Optional> *phone;
@property (nonatomic, readwrite) NSString<Optional> *cameraUrl;
@property (nonatomic, readwrite) Location<Optional> *location;
- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier emailId:(NSString *)emailId phone:(NSNumber *)phone cameraUrl:(NSString *)cameraUrl andLocation:(Location *)locaition;
@end
