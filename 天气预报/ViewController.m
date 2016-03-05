//
//  ViewController.m
//  天气预报
//
//  Created by mac on 16/1/1.
//  Copyright © 2016年 mac. All rights reserved.
//


#import "ViewController.h"
#import "UIViewExt.h"

@interface ViewController ()

@end

IB_DESIGNABLE
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _loadCity];
    [self pickerView:self.pickerView didSelectRow:0 inComponent:1];
}

//读取省市列表plist数据
- (void)_loadCity {
    
    _provinces = [NSMutableArray array];
    _cities = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Provineces" ofType:@"plist"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic in arr) {
        NSArray *array = dic[@"cities"];
        Province *province = [[Province alloc]init];
        NSMutableArray *cities = [NSMutableArray array];
        for (NSDictionary *cityDic in array) {
            City *city = [[City alloc]init];
            city.name = cityDic[@"CityName"];
//            [self _downLoadCityCode:city];
            [cities addObject:city];
        }
        province.name = dic[@"ProvinceName"];
        province.cities = cities;
        [_provinces addObject:province];
    }
    _cities = ((Province *)_provinces[0]).cities;
}

//从接口获取城市的代码
- (void)_downLoadCityCode:(City *)city {
    NSString *cityName = city.name;
    NSString *urlStr = [cityName stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURL *codeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://apis.baidu.com/apistore/weatherservice/cityname?cityname=%@",urlStr]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:codeUrl];
    request.HTTPMethod = @"GET";
    [request setValue:@"8e75bfe0b994ad2ba4e4b644c5bf088f" forHTTPHeaderField:@"apikey"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSError *JsonError = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&JsonError];
            id cityDic = dic[@"retData"];
//            如果数据请求成功，就继续用code请求weather数据
            if ([cityDic isKindOfClass:[NSDictionary class]]) {
                NSNumber *code = cityDic[@"citycode"];
                city.code = code;
                [self _requestWeather:city];
            }
//            如果数据请求失败，就给city对象装入一个errorWeather
            else {
                city.weather = [WeatherModel errorWeather];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _showDetailWithWeather:city.weather];
                });
            }
        }
    }];
    [task resume];
    
}

//请求天气数据的方法
- (void)_requestWeather:(City *)city {
    NSNumber *cityCode = city.code;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://apis.baidu.com/apistore/weatherservice/cityid?cityid=%@",cityCode]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request setValue:@"8e75bfe0b994ad2ba4e4b644c5bf088f" forHTTPHeaderField:@"apikey"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        NSDictionary *modelDic = dic[@"retData"];
        WeatherModel *model = [[WeatherModel alloc]initContentWithDic:modelDic];
        city.weather = model;
//        显示当前选择城市的天气
        dispatch_async(dispatch_get_main_queue(), ^{
                
            [self _showDetailWithWeather:model];
        });
    }];
    [task resume];
}

//根据model显示相应的天气
- (void)_showDetailWithWeather:(WeatherModel *)model {
    ((UILabel *)[_weatherDetail viewWithTag:100]).text = [NSString stringWithFormat:@"城市：%@",model.city];
    ((UILabel *)[_weatherDetail viewWithTag:101]).text = [NSString stringWithFormat:@"天气：%@",model.weather];
    ((UILabel *)[_weatherDetail viewWithTag:102]).text = [NSString stringWithFormat:@"温度：%@",model.temp];
    ((UILabel *)[_weatherDetail viewWithTag:103]).text = [NSString stringWithFormat:@"风向：%@",model.WD];
    ((UILabel *)[_weatherDetail viewWithTag:104]).text = [NSString stringWithFormat:@"风力：%@",model.WS];
    ((UILabel *)[_weatherDetail viewWithTag:105]).text = [NSString stringWithFormat:@"最近更新时间：%@ %@",model.date,model.time];
    
    _weatherPic.image = [UIImage imageNamed:model.weather];
    CATransition *transition = [[CATransition alloc]init];
    transition.type = @"rippleEffect";
    transition.duration = 0.5;
    [_weatherPic.layer addAnimation:transition forKey:@"transition"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - pickerViewDataSource

//选中城市时调用的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        Province *province = _provinces[row];
        _cities = province.cities;
        [self.pickerView reloadComponent:1];
//        让城市列表显示第一个
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [self pickerView:pickerView didSelectRow:0 inComponent:1];
    }
    else {
        City *city = _cities[row];
        if (city.weather == nil) {
            [self _downLoadCityCode:city];
            [self _showDetailWithWeather:[WeatherModel loadingWeather]];
        }
        else {
            [self _showDetailWithWeather:city.weather];
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        
        return _provinces.count;
    }
    else {
        
        NSInteger index = [pickerView selectedRowInComponent:0];
        Province *province = _provinces[index];
        return province.cities.count;
    }
}

//返回需要显示的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, pickerView.width, 30)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    if (component == 0) {
        Province *province = _provinces[row];
        label.text = province.name;
    }
    if (component == 1) {
        City *city = _cities[row];
        label.text = city.name;
    }
    return label;
}

@end
