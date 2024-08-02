//
//  User.h
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Dto.h"
@interface User : JSONModel<Dto>
@property (nonatomic, readwrite) NSString *Email;
@property (nonatomic, readwrite) NSString *UserName;
@property (nonatomic, readwrite) NSString<Optional> *Password;
@property (nonatomic, readwrite) NSString<Optional> *identifier;
//profile
@property (nonatomic, readwrite) NSString<Optional> *firstName;
@property (nonatomic, readwrite) NSString<Optional> *lastName;
@property (nonatomic, readwrite) NSString<Optional> *contactNumber;
@property (nonatomic, readwrite) NSString<Optional> *profilePicture;
@property (nonatomic, readwrite) NSString<Optional> *profilePictureThumbnail;
@property (nonatomic, readwrite) NSNumber<Optional> *gender;
@property (nonatomic, readwrite) NSString<Optional> *dob;
@property (nonatomic, readwrite) NSNumber<Optional> *userType;
@property (nonatomic, readwrite) NSString<Optional> *sessionToken;
@property (nonatomic, readwrite) Location<Optional> *location;
@end
