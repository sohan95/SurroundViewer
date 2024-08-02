//
//  User.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "User.h"

@implementation User
+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"LastName": @"lastName",
                                                       @"FirstName": @"firstName",
                                                       @"SessionToken": @"sessionToken",
                                                       @"ContactNumber": @"contactNumber",
                                                       @"Gender": @"gender",
                                                       @"ProfilePictureThumbnail":@"profilePictureThumbnail",
                                                       @"ProfilePicture":@"profilePicture",
                                                       @"DOB":@"dob",
                                                       @"Id":@"identifier"
                                                       }];
}
@end
