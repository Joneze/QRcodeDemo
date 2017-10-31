//
//  QRCodeViewController.m
//  QRCodeDemo
//
//  Created by jay on 2017/10/30.
//  Copyright © 2017年 曾辉. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "JMQRCodeView.h"
/**
 *  屏幕 高 宽 边界
 */
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

@interface QRCodeViewController ()


@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCamera];
    
    self.title = @"扫一扫";
}

-(void)setupCamera
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    JMQRCodeView *qrView = [JMQRCodeView new];
    
    qrView.JMQRCodeViewcaptureOutputBlock = ^(NSString *stringValue) {
        NSLog(@"扫一扫结果回调:%@",stringValue);
        //这里可以做 扫描成功后的操作
    };
    [self.view addSubview:qrView];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
