//
//  ViewController.m
//  QRCodeDemo
//
//  Created by jay on 2017/10/30.
//  Copyright © 2017年 曾辉. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager  *locationManager;
@property(nonatomic,strong)CLGeocoder * geoCoder ;
@property(nonatomic,copy)NSString * currentCity; //当前城市
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _geoCoder = [[CLGeocoder alloc] init];
    [self locate];
    
}
- (void)locate {
    //判断定位功能是否打开
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue]>8.0) {
            
            [self.locationManager requestAlwaysAuthorization];//添加这句
            
        } 
        [_locationManager startUpdatingLocation];
    }
    
}

#pragma mark CoreLocation delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"经度=%f 纬度=%f 高度=%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude, currLocation.altitude);
    
    //反编码
    [_geoCoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            _currentCity = placeMark.locality;
            if (!_currentCity) {
                _currentCity = @"无法定位当前城市";
            }
            NSLog(@"%@",_currentCity); //这就是当前的城市
            NSLog(@"%@",placeMark.name);//具体地址:  xx市xx区xx街道
        }
        else if (error == nil && placemarks.count == 0) {
            NSLog(@"No location and error return");
        }
        else if (error) {
            NSLog(@"location error: %@ ",error);
        }
        
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        //访问被拒绝
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
}

- (IBAction)pushToVc:(id)sender {
    QRCodeViewController *qrCode = [QRCodeViewController new];
    [self.navigationController pushViewController:qrCode animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
