//
//  BRSendETHViewController.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-11-28.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRSendETHViewController.h"


@interface BRSendETHViewController ()

@end

@implementation BRSendETHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"BRSendETHViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"BRSendETHViewController viewWillAppear");
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (BOOL)nextTip {
    return NO;
}

- (void)viewBTC{
    [self.pageViewController setViewControllers:@[self.sendViewController]
                                      direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (IBAction)showBTC:(id)sender {
    [self.pageViewController setViewControllers:@[self.sendViewController]
                                      direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

@end
