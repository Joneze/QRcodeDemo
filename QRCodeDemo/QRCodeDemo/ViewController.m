//
//  ViewController.m
//  QRCodeDemo
//
//  Created by jay on 2017/10/30.
//  Copyright © 2017年 曾辉. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
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
