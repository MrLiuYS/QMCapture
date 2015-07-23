//
//  ViewController.m
//  QMCapture
//
//  Created by 刘永生 on 15/7/23.
//  Copyright (c) 2015年 刘永生. All rights reserved.
//

#import "ViewController.h"

#import "IdiomData.h"

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [IdiomData idiomList];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
