//
//  Http.m
//  SurroundViewer
//
//  Created by Md. Shahanur Rahmann on 4/17/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "SurroundDefine.h"
#import "HTTPCodes.h"
#import "JsonUtil.h"
#import "Cameras.h"
#import "Utility.h"
#import "Http.h"
#import "User.h"
@interface Http(){

    SurroundViewer *_surroundViewer;
    id<Progress> _progress;
}
@end
@implementation Http

- (instancetype)initWithSurroundViewer:(SurroundViewer *)surroundViewer andProgress:(id<Progress>)progress {
    if (self = [self init]) {
        _surroundViewer = surroundViewer;
        _progress = progress;
    }
    return self;
}

- (instancetype)initWithProgress:(id<Progress>)progress {

    if (self == [super init]) {
        _progress = progress;
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        self.defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.defaultSession = [NSURLSession sessionWithConfiguration:self.defaultConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods

- (void)getFriendsCameras:(SAObjectResultBlock)block {
//    //TODO::Create proper url request
    /*NSString *urlString ;
    NSURLRequest *urlRequest;
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];*/
    id friendscameras = [JsonUtil loadObject:NSStringFromClass([FriendsCameras class]) withFile:@"friendcameras"];
    block(friendscameras,nil);
}

- (void)getUserPackageByUserIDForMobileAppWithCompletionBlock:(SAObjectResultBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@",URL_SCHEMA,_surroundViewer.conf.fileServerAddr,URL_BASE_PATH,URL_GET_USER_PACKAGE];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:[self requestBody] andQuery:nil];
    
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}

- (void)authenticateUser:(SAObjectResultBlock)block {

    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@",URL_SCHEMA,_surroundViewer.conf.fileServerAddr,URL_BASE_PATH_2,URL_GET_USER_LOGIN];
    NSURLRequest *urlRequest = [self requestWithMethod:@"POST" withUrlString:urlString requestbody:[_surroundViewer.conf toDictionary] andQuery:nil];
    [self initURLSessionWithRequest:urlRequest andCompltetionHandler:block];
}
#pragma mark -
#pragma mark - Class Merthods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method withUrlString:(NSString *)urlStr requestbody:(NSDictionary *)requestDictionary andQuery:(NSString *)query {
    
    NSLog(@"SurroundViewer Http method=%@",method);
    NSLog(@"SurroundViewer Http url=%@",urlStr);
    NSLog(@"SurroundViewer Http query=%@",query);
    NSLog(@"SurroundViewer Http rerquest Dictionary=%@",requestDictionary);
    NSMutableURLRequest *urlRequest = nil;
    
    NSMutableString *spec = [[NSMutableString alloc] initWithString:urlStr];
    
    if ([method isEqualToString:@"GET"]) {
        if (urlStr && [urlStr length] > 0 && ![urlStr isEqual:[NSNull class]]) {
            [spec appendString:[NSString stringWithFormat:@"?%@",query]];
        }
    }
    NSURL *url = [NSURL URLWithString:spec];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.timeoutInterval = kRequestTimeOut;
    urlRequest.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([method isEqualToString:@"POST"]) {
        NSError *error = nil;
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:NSJSONWritingPrettyPrinted error:&error];
        [urlRequest setHTTPBody:requestData];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    }
    return urlRequest;
}

- (NSString*)queryWithQuery:(NSString *)query {
    
    query = [query stringByReplacingOccurrencesOfString:@"$sessionToken$" withString:_surroundViewer.user.sessionToken ? _surroundViewer.user.sessionToken : @""];
    query = [query stringByReplacingOccurrencesOfString:@"$ID$" withString:_surroundViewer.conf.appId ? [_surroundViewer.conf.appId stringValue] : @""];
    return query;
}

- (NSDictionary *)requestBody {
    return @{@"sessionToken":_surroundViewer.user.sessionToken,
             @"ID":_surroundViewer.conf.appId};
}

- (NSMutableURLRequest *)createRequestWithUrl:(NSURL *)url andRequestData:(NSData *)requestData {
    //create url request for the url
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kRequestTimeOut];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    return urlRequest;
}

- (NSMutableURLRequest *)createRequestForCamera:(NSString*)cameraStrg {
    //create url request for the url
     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",cameraStrg,cameraStrg]];
    
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    return urlRequest;
}

- (void)parseResponseForObjectBlock:(NSHTTPURLResponse *)httpResponse withError:(NSError **)error_p completionBlock:(SAObjectResultBlock)block andWithData:(NSData *)data {
    
    NSString *statusDesc = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
    if (httpResponse.statusCode == HTTPCode200OK) {
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&(*error_p)];
        //TODO:PARSE
        block(responseDictionary[@"Result"],nil);
    }else if (httpResponse.statusCode == HTTPCode400BadRequest){
        [_progress toast:BAD_REQUEST];
        block(nil,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else if (httpResponse.statusCode == HTTPCode401Unauthorised){
        [_progress toast:UNAUTHORIZED];
        block(nil,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }else{
        [_progress toast:UNKNOWN];
        block(nil,[NSError errorWithDomain:@"Internal Server Error" code:httpResponse.statusCode userInfo:@{@"user info":statusDesc}]);
    }
}

- (void)initURLSessionWithRequest:(NSURLRequest *)urlRequest andCompltetionHandler:(SAObjectResultBlock)block{
    
    NSURLSessionDataTask *task = [self.defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data,NSURLResponse *response, NSError *error){
        @try {
            if (error) {
                block(nil,error);
            }else {
                NSError *err;
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                [self parseResponseForObjectBlock:httpResponse withError:&err completionBlock:block andWithData:data];
            }
        }
        @catch (NSException *exception) {
            @throw exception;
        }
        @finally {
            
        }
    }];
    [task resume];
}
@end
