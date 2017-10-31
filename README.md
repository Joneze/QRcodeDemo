# QRCodeDemo
##### iOS 原生代码实现扫描二维码/条形码
利用AVFoundation框架实现扫码需求。


使用方式直接导入文件 JMQRCodeView.h 和.m文件

```
JMQRCodeView *qrView = [JMQRCodeView new];
    
    qrView.JMQRCodeViewcaptureOutputBlock = ^(NSString *stringValue) {
        NSLog(@"扫一扫结果回调:%@",stringValue);
        //这里可以做 扫描成功后的操作
    };
    [self.view addSubview:qrView];
    
```


以下是效果图
![效果图](https://github.com/Joneze/QRcodeDemo/blob/master/QRCodeDemo/qrcode.jpeg)


