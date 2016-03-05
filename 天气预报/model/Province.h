//
//  Province.h
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"

@interface Province : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSMutableArray<City *> *cities;

@end
