//
//  ViewController.m
//  CarthageProj
//
//  Created by 宓珂璟 on 2020/6/27.
//  Copyright © 2020 Deft_Mikejing_iOS_coder. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <Masonry/Masonry.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(120, 60));
    }];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"当前网络状态->%@",@(status));
    }];
}


- (void)start:(id)sender{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (UIButton *)button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button setBackgroundColor:[UIColor redColor]];
        [_button setTitle:@"开始" forState:UIControlStateNormal];
        [_button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _button.layer.cornerRadius = 5.0f;
        [_button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}


@end
