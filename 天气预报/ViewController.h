//
//  ViewController.h
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Province.h"
#import "City.h"
#import "WeatherModel.h"

@interface ViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, copy)NSMutableArray *provinces;
@property (nonatomic, copy)NSMutableArray *cities;

@property (weak, nonatomic) IBOutlet UIStackView *weatherDetail;
@property (weak, nonatomic) IBOutlet UIImageView *weatherPic;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualView;

@end

