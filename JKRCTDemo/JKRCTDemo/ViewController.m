//
//  ViewController.m
//  JKRCTDemo
//
//  Created by Lucky on 2018/2/7.
//  Copyright © 2018年 Lucky. All rights reserved.
//

#import "ViewController.h"
#import "JKRTextLabel.h"
#import "JKRImageTextLabel.h"

@interface ViewController ()

@property (nonatomic, strong) JKRTextLabel *textLabel;
@property (nonatomic, strong) JKRImageTextLabel *imageLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.textLabel = [[JKRTextLabel alloc] initWithFrame:CGRectMake(0, 20, 300, 40)];
//    self.textLabel.backgroundColor = [UIColor yellowColor];
//    self.textLabel.userInteractionEnabled = YES;
//    [self.view addSubview:self.textLabel];
    
    self.imageLabel = [[JKRImageTextLabel alloc] initWithFrame:CGRectMake(0, 80, 300, 50)];
    self.imageLabel.backgroundColor = [UIColor yellowColor];
    self.imageLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.imageLabel];
}


@end
