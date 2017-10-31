//
//  JMQRCodeView.h
//  QRCodeDemo
//
//  Created by jay on 2017/10/31.
//  Copyright © 2017年 曾辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMQRCodeView : UIView

@property (nonatomic, copy)void(^JMQRCodeViewcaptureOutputBlock)(NSString *stringValue);

@end
