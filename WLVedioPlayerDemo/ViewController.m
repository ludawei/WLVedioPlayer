//
//  ViewController.m
//  WLVedioPlayerDemo
//
//  Created by 卢大维 on 15/7/22.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 100, 40)];
    [button setTitle:@"click" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)clickButton
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoviewdemo" ofType:@"mp4"];
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];

    
    PlayerViewController *next = [PlayerViewController new];
    next.url = filePath;
    [self presentViewController:next animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
