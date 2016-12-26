//
//  ViewController.m
//  XPAdCarouselView
//
//  Created by xp2012 on 2016/12/26.
//  Copyright © 2016年 xp. All rights reserved.
//

#import "ViewController.h"
#import "XPAdCarouselView.h"

@interface ViewController ()<XPAdCarouselViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    XPAdCarouselView *adScrollView = [[XPAdCarouselView alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
    adScrollView.delegate = self;
    adScrollView.center = self.view.center;
    adScrollView.layer.cornerRadius = 15;
    adScrollView.layer.masksToBounds = YES;
    adScrollView.layer.allowsEdgeAntialiasing = true;
    [self.view addSubview:adScrollView];
    [adScrollView setAdDataToCarouseView:@[@"http://res9.weplay.cn/app/www/templates/common/img/upload/appFind/1482339770.png",@"http://res9.weplay.cn/app/www/templates/common/img/upload/appFind/1482339794.png",@"http://res9.weplay.cn/app/www/templates/common/img/upload/appFind/1482339819.png",@"http://res9.weplay.cn/app/www/templates/common/img/upload/appFind/1482339864.png",@"http://res9.weplay.cn/app/www/templates/common/img/upload/appFind/1482339892.png"]];
}

- (void)selectedCurrentCarouseView:(NSInteger)page {
    NSLog(@"选择了第几页 %ld",(long)page);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
