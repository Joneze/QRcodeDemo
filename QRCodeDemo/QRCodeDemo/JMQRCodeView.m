//
//  JMQRCodeView.m
//  QRCodeDemo
//
//  Created by jay on 2017/10/31.
//  Copyright © 2017年 曾辉. All rights reserved.
//

#import "JMQRCodeView.h"
#import <AVFoundation/AVFoundation.h>

/**
 *  屏幕 高 宽 边界
 */
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.34
/** 扫描内容的X值 */
#define scanContent_X self.frame.size.width * 0.15

#define layerBounds    [UIScreen mainScreen].bounds


@interface JMQRCodeView ()<AVCaptureMetadataOutputObjectsDelegate>

{
    CAShapeLayer *cropLayer;
    UIImageView *lineImgView;
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, strong) UIImageView * line;

@end


@implementation JMQRCodeView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        [self setCropRect:CGRectMake(scanContent_X, scanContent_Y, (layerBounds.size.width - 2 * scanContent_X), (layerBounds.size.width - 2 * scanContent_X))];
        [self QRCodeViewUI];
    }
    return self;
}

-(void)QRCodeViewUI
{
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //3.1 设置扫码框作用范围 (由于扫码时系统默认横屏关系, 导致作用框原点变为我们绘制的框的右上角,而不是左上角) 且参数为比率不是像素点
        _output.rectOfInterest = CGRectMake(scanContent_Y/layerBounds.size.height, scanContent_X/layerBounds.size.width, (layerBounds.size.width - 2 * scanContent_X)/layerBounds.size.height, (layerBounds.size.width - 2 * scanContent_X)/layerBounds.size.width);
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.layer.bounds;
    [self.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}

#pragma mark  ======== 画扫描框 =========
- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    
    [cropLayer setNeedsDisplay];
    
    [self.layer addSublayer:cropLayer];
    
//    CALayer *scanContent_layer = self.layer;
    CGFloat scanContent_layerW = layerBounds.size.width - 2 * scanContent_X;
//    CGFloat scanContent_layerH = scanContent_layerW;
    
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scanContent_X, scanContent_Y, (layerBounds.size.width - 2 * scanContent_X), (layerBounds.size.width - 2 * scanContent_X))];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(scanContent_X, scanContent_Y + 10, (layerBounds.size.width - 2 * scanContent_X), 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self addSubview:_line];
    
    
    //4 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = CGRectGetMaxY(imageView.frame) + 30;
    CGFloat promptLabelW = self.frame.size.width;
    CGFloat promptLabelH = 25;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"将二维码/条码放入框内,以便扫描";
    [self addSubview:promptLabel];

    //5 添加闪光灯按钮
//    UIImage *light_open_img = [UIImage imageNamed:@"SGQRCode.bundle/qrcode_scan_btn_nor"];
//    UIImage *light_off_img = [UIImage imageNamed:@"SGQRCode.bundle/qrcode_scan_btn_off"];
//    UIButton *light_button = [[UIButton alloc] init];
//    CGFloat light_buttonX = 0;
//    CGFloat light_buttonY = CGRectGetMaxY(promptLabel.frame) + 10;
//    CGFloat light_buttonW = light_open_img.size.width;
//    CGFloat light_buttonH = light_open_img.size.height;
//    light_button.frame = CGRectMake(light_buttonX, light_buttonY, light_buttonW, light_buttonH);
////    light_button.center = CGPointMake(self.center.x, light_buttonY);
//    [light_button setImage:light_open_img forState:UIControlStateNormal];
//    [light_button setImage:light_off_img forState:UIControlStateSelected];
//    [light_button addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:light_button];
    
    
    
//    // line移动的范围为 一个扫码框的高度(由于图片问题再减去图片的高度和图片的起始高度)
    CABasicAnimation * lineAnimation = [self animationWith:@(0) toValue:@((layerBounds.size.width - 2 * scanContent_X) - 16) repCount:MAXFLOAT duration:1.5f];
    [_line.layer addAnimation:lineAnimation forKey:@"LineImgViewAnimation"];
    
}

#pragma mark  ======== 扫描结果回调 =========
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0){
        //停止扫描
        [_session stopRunning];
        //取消line动画
        [self removeAnimationAboutScan];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
    }
}

//#pragma mark - - - 照明灯的点击事件
//- (void)light_buttonAction:(UIButton *)button {
//    if (button.selected == NO) { // 点击打开照明灯
//        [self turnOnLight:YES];
//        button.selected = YES;
//    } else { // 点击关闭照明灯
//        [self turnOnLight:NO];
//        button.selected = NO;
//    }
//}
//
//
//
//#pragma mark - 开关灯功能
//- (void)turnOnLight:(BOOL)on {
//    //1.是否存在手电功能
//    if ([_device hasTorch]) {
//        //2.锁定当前设备为使用者
//        [_device lockForConfiguration:nil];
//        //3.开关手电筒
//        if (on) {
//            [_device setTorchMode:AVCaptureTorchModeOn];
//        } else {
//            [_device setTorchMode: AVCaptureTorchModeOff];
//        }
//        //4.使用完成后解锁
//        [_device unlockForConfiguration];
//    }
//}

#pragma mark - 扫码line滑动动画
- (CABasicAnimation*)animationWith:(id)fromValue toValue:(id)toValue repCount:(CGFloat)repCount duration:(CGFloat)duration{
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    lineAnimation.fromValue = fromValue;
    lineAnimation.toValue = toValue;
    lineAnimation.repeatCount = repCount;
    lineAnimation.duration = duration;
    lineAnimation.fillMode = kCAFillModeForwards;
    lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return lineAnimation;
}
- (void)removeAnimationAboutScan{
    
    [_line.layer removeAnimationForKey:@"LineImgViewAnimation"];
    _line.hidden = YES;
}

@end
