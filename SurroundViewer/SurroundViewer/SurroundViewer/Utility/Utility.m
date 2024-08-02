//
//  Utility.m
//  SurroundViewer
//
//  Created by makboney on 5/9/16.
//  Copyright © 2016 Sansongs Corporation. All rights reserved.
//

#import "ChanelCategory.h"
#import "Utility.h"
#import "Camera.h"
#import "FriendsCamera.h"

@implementation Utility
+ (NSDictionary *)getMyChannels:(NSDictionary *)jsonDataDic {
    
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:5];
    for (int index = 0; index < 5; index++) {
        NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity:10];
        for (int subIndex = 0; subIndex < 10; subIndex++) {
            Channel *channel = [[Channel alloc] initWithName:[NSString stringWithFormat:@"Channel-%d%d",subIndex,index]
                                                  identifier:[NSString stringWithFormat:@"Identifier_Channel_%d%d",subIndex,index]
                                                   streamUrl:[NSString stringWithFormat:@"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"]
                                             channelImageUrl:[NSString stringWithFormat:@"http://imageurl%d%d.com",subIndex,index]];
            [channels addObject:channel];
        }
        ChanelCategory *category = [[ChanelCategory alloc] initWithName:[NSString stringWithFormat:@"TV Channel Category-%d",index]
                                                             identifier:[NSString stringWithFormat:@"Identifier_Category_%d",index]
                                                       categoryImageUrl:[NSString stringWithFormat:@"http://imageurl%d.com",index]
                                                             andChannel:channels];
        [categories addObject:category];
    }
    return [NSDictionary dictionaryWithObject:categories forKey:@"result"];
}

+ (NSDictionary *)getMyCameras:(NSDictionary *)jsonDataDic {
    NSArray *jsonDataArry = [jsonDataDic valueForKey:@"rows"];
    NSMutableArray *cameras = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary *cameraDic in jsonDataArry) {
        Location *location = [[Location alloc]
                              initWithLatitude:[cameraDic valueForKey:@"latitude"]
                              longitude:[cameraDic valueForKey:@"longitude"]
            andImageMap:nil];
        
        Camera *camera = [[Camera alloc]
            initWithTitle:[cameraDic valueForKey:@"title"]
            identifier:[cameraDic valueForKey:@"identifier"]
            ipAddress:[cameraDic valueForKey:@"ipAddress"]
            userName:[cameraDic valueForKey:@"userName"]
            passWord:[cameraDic valueForKey:@"password"]
            andLocation:location];
        
        [cameras addObject:camera];
    }
    return [NSDictionary dictionaryWithObject:cameras forKey:@"result"];
}

+ (NSDictionary *)getMyFriendCams:(NSDictionary *)jsonDataDic {
    NSArray *jsonDataArry = [jsonDataDic valueForKey:@"rows"];
    NSMutableArray *friendsCams = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary *fCamDic in jsonDataArry) {
        Location *location = [[Location alloc]
                              initWithLatitude:[fCamDic valueForKey:@"latitude"]
                              longitude:[fCamDic valueForKey:@"longitude"]
                              andImageMap:nil];
        
        FriendsCamera *friendsCam = [[FriendsCamera alloc]
                initWithName:[fCamDic valueForKey:@"name"]
                identifier:[fCamDic valueForKey:@"identifier"]
                emailId:[fCamDic valueForKey:@"emailId"]
                phone:[fCamDic valueForKey:@"phone"]
                cameraUrl:[fCamDic valueForKey:@"cameraUrl"]
                andLocation:location];
        
        [friendsCams addObject:friendsCam];
    }
    return [NSDictionary dictionaryWithObject:friendsCams forKey:@"result"];
}

+ (NSDictionary *)getMyCameras {
    
    NSMutableArray *cameras = [[NSMutableArray alloc] initWithCapacity:10];
    for (int index = 0; index < 10; index++) {
        Location *location = [[Location alloc] initWithLatitude:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"23.4598456%d",index] doubleValue]]
                                                      longitude:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"56.60144%d",index] doubleValue]]
                                                    andImageMap:nil];
        
        Camera *camera = [[Camera alloc] initWithTitle:[NSString stringWithFormat:@"Camera-%d",index]
                                            identifier:[NSString stringWithFormat:@"Identifier_Camera_%d",index]
                                             ipAddress:@"50.242.178.52"
                                              userName:@"admin"
                                              passWord:@"Test123@"
                                           andLocation:location];
        
        [cameras addObject:camera];
    }
    return [NSDictionary dictionaryWithObject:cameras forKey:@"result"];
}

+ (NSDictionary *)getMyChannels {
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:5];
    for (int index = 0; index < 5; index++) {
        NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity:10];
        for (int subIndex = 0; subIndex < 10; subIndex++) {
            Channel *channel = [[Channel alloc] initWithName:[NSString stringWithFormat:@"Channel-%d%d",subIndex,index]
                    identifier:[NSString stringWithFormat:@"Identifier_Channel_%d%d",subIndex,index]
                    streamUrl:[NSString stringWithFormat:@"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"]
                    channelImageUrl:[NSString stringWithFormat:@"http://imageurl%d%d.com",subIndex,index]];
            [channels addObject:channel];
        }
        ChanelCategory *category = [[ChanelCategory alloc] initWithName:[NSString stringWithFormat:@"TV Channel Category-%d",index]
                    identifier:[NSString stringWithFormat:@"Identifier_Category_%d",index]
                    categoryImageUrl:[NSString stringWithFormat:@"http://imageurl%d.com",index]
                    andChannel:channels];
        [categories addObject:category];
    }
    return [NSDictionary dictionaryWithObject:categories forKey:@"result"];
}

+ (NSDictionary *)getMyFriendCams {
    
    NSMutableArray *friendsCams = [[NSMutableArray alloc] initWithCapacity:10];
    for (int index = 0; index < 10; index++) {
        Location *location = [[Location alloc] initWithLatitude:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"23.4598456%d",index] doubleValue]] longitude:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"56.60144%d",index] doubleValue]] andImageMap:nil];
        
        FriendsCamera *friendsCam = [[FriendsCamera alloc] initWithName:[NSString stringWithFormat:@"FriendsCamera-%d",index]
            identifier:[NSString stringWithFormat:@"Identifier_FriendsCamera_%d",index]
            emailId:[NSString stringWithFormat:@"friendscamera%d@gmail.com",index]
            phone:[NSNumber numberWithInt:[[NSString stringWithFormat:@"880172250001%d",index] integerValue]]
            cameraUrl:@"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
            andLocation:location];
        
        [friendsCams addObject:friendsCam];
    }
    return [NSDictionary dictionaryWithObject:friendsCams forKey:@"result"];
}
@end
