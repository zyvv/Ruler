//
//  ViewController.m
//  Ruler
//
//  Created by 张洋威 on 16/4/18.
//  Copyright © 2016年 太阳花互动. All rights reserved.
//

#import "ViewController.h"
#import "RulerView.h"

@interface ViewController ()<RulerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel;
@property (weak, nonatomic) IBOutlet RulerView *rulerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rulerView.delegate = self;
}

- (void)rulerView:(RulerView *)rulerView currentValue:(NSInteger)currentValue {
    _currentSizeLabel.text = [NSString stringWithFormat:@"%ld", currentValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
