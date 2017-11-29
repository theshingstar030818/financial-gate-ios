//
//  BRSendADAViewController.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-11-28.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRSendADAViewController.h"

static NSString *sanitizeString(NSString *s)
{
    NSMutableString *sane = [NSMutableString stringWithString:(s) ? s : @""];
    
    CFStringTransform((CFMutableStringRef)sane, NULL, kCFStringTransformToUnicodeName, NO);
    return sane;
}

@interface BRSendADAViewController ()

@end

@implementation BRSendADAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"BRSendADAViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"BRSendADAViewController viewWillAppear");
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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
