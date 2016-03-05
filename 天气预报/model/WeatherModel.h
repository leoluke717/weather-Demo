//
//  WeatherModel.h
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "BaseModel.h"

@interface WeatherModel : BaseModel

@property (nonatomic, copy)NSString *temp;
@property (nonatomic, copy)NSString *weather;
@property (nonatomic, copy)NSString *city;
@property (nonatomic, copy)NSString *WD;
@property (nonatomic, copy)NSString *WS;
@property (nonatomic, copy)NSString *date;
@property (nonatomic, copy)NSString *time;

+ (instancetype)loadingWeather;
+ (instancetype)errorWeather;
@end
