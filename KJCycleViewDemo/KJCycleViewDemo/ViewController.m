//
//  ViewController.m
//  KJCycleViewDemo
//
//  Created by KepenJ on 15/12/8.
//  Copyright © 2015年 KepenJ. All rights reserved.
//

#import "ViewController.h"
#import "KJCycleView.h"
@interface ViewController ()<KJCycleViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    KJCycleView * kjView = [[KJCycleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
    kjView.delelgate = self;
    kjView.imageArr = @[[UIImage imageNamed:@"1.jpg"],
                        [UIImage imageNamed:@"2.jpg"],
                        [UIImage imageNamed:@"3.jpg"],
                        [UIImage imageNamed:@"4.jpg"]];
    kjView.isAutoScrol = YES;
    kjView.isMakeBottomRoundCorner = YES;
    [self.view addSubview:kjView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KJCycleViewDelegate
- (void)kJCycleView:(KJCycleView *)target didTapViewsAtIndex:(NSInteger)index {
    NSLog(@"%ld",(long)index);
}
@end
