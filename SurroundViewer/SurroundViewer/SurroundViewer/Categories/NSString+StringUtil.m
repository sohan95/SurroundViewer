//
//  NSString+StringUtil.m
//  SurroundViewer
//
//  Created by makboney on 3/18/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "NSString+StringUtil.h"

@implementation NSString (StringUtil)

-(BOOL)isEmptyString{
    if (self == NULL || [self isEqualToString:@""] || self.length <=0) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isEmptyStringRemovingWhiteSpace{
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string == NULL || [string isEqualToString:@""] || string.length <=0) {
        return YES;
    }else{
        return NO;
    }
}

@end
