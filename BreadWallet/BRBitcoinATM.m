//
//  BRBitcoinATM.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-25.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRBitcoinATM.h"
#import "BROptionViewController.h"
#import "BRRootViewController.h"
#import "BRSettingsViewController.h"
#import "BRTxDetailViewController.h"
#import "BRSeedViewController.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "UIImage+Utils.h"
#import "BREventConfirmView.h"
#import "BREventManager.h"
#import "FinancialGate-Swift.h"
#import <WebKit/WebKit.h>

@interface BRBitcoinATM ()


@end

@implementation BRBitcoinATM

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    self.tableView.alpha = 1.0;
    self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
//    BRWalletManager *manager = [BRWalletManager sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {

}

- (IBAction)viewAtmDetai:(id)sender
{
    if([sender tag] == 1){
        NSLog(@"View ATM Detail : BitcoinATMTokyoWallStreetCafeStoryboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATMTokyoWallStreetCafeStoryboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }else if([sender tag] == 2){
        NSLog(@"View ATM Detail : BitcoinATMTokyoCafeWorldStoryboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATMTokyoCafeWorldStoryboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }else if([sender tag] == 3){
        NSLog(@"View ATM Detail : BitcoinATMOsakaChefKitchenStoryboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATMOsakaChefKitchenStoryboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }else if([sender tag] == 4){
        NSLog(@"View ATM Detail : BitcoinATMHiroshima1Storyboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATMHiroshima1Storyboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }else if([sender tag] == 5){
        NSLog(@"View ATM Detail : BitcoinATMMiyagiMiyagi1Storyboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATMMiyagiMiyagi1Storyboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }else if([sender tag] == 6){
        NSLog(@"View ATM Detail : BitcoinATMHOKKAIDO1Storyboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATMHOKKAIDO1Storyboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }else if([sender tag] == 7){
        NSLog(@"View ATM Detail : BitcoinATM KANAGAWA1Storyboard");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BitcoinATM KANAGAWA1Storyboard"
                                                             bundle:nil];
        UIViewController *destinationController = [storyboard instantiateViewControllerWithIdentifier:@"BRBitcoinATM"];
        [self.navigationController pushViewController:destinationController animated:YES];
    }
    
}

@end
