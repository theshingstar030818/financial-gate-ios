//
//  BRWalletETHManager.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-02.
//

@import NotificationCenter;

#import <ethers/SecureData.h>
#import <ethers/Transaction.h>
#import <Foundation/Foundation.h>

#import "Wallet.h"
#import "Reachability.h"
#import "BRWalletETHManager.h"

#import "ApplicationViewController.h"
#import "CloudView.h"
#import "ConfigNavigationController.h"
#import "GasPriceKeyboardView.h"
#import "ModalViewController.h"
#import "OptionsConfigController.h"
#import "PanelViewController.h"
#import "ScannerConfigController.h"
#import "SharedDefaults.h"
#import "SignedRemoteDictionary.h"
#import "UIColor+hex.h"
#import "Utilities.h"
#import "Wallet.h"
#import "WalletViewController.h"

// The Canary is a signed payload living on the ethers.io web server, which allows the
// authors to notify users of critical issues with either the app or the Ethereum network
// The scripts/tools directory contains the code that generates a signed payload.
#define CANARY_ADDRESS    @"0x70C14080922f091fD7d0E891eB483C9f8464a527"

static NSString *CanaryUrl = @"https://ethers.io/canary.raw";

// Test URL - This URL triggers the canaray for testing purposes
//static NSString *CanaryUrl = @"https://ethers.io/canary-test.raw";

static Address *CanaryAddress = nil;
static NSString *CanaryVersion = nil;



@interface BRWalletETHManager()

@property (nonatomic, strong) Wallet *wallet;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, readonly) WalletViewController *walletViewController;

@end

@implementation BRWalletETHManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CanaryAddress = [Address addressWithString:CANARY_ADDRESS];
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        CanaryVersion = [NSString stringWithFormat:@"%@/%@", [info objectForKey:@"CFBundleIdentifier"],
                         [info objectForKey:@"CFBundleShortVersionString"]];
        
        NSLog(@"Canary Version: %@", CanaryVersion);
        singleton = [self new];
    });
    return singleton;
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    _wallet = [Wallet walletWithKeychainKey:@"io.ethers.sharedWallet"];
    _walletViewController = [[WalletViewController alloc] initWithWallet:_wallet];
    return self;
}

- (void)protectedInit
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
}

- (void)dealloc
{
    
}

- (Wallet *)wallet
{
    if (_wallet) return _wallet;
    return _wallet;
}

// true if keychain is available and we know that no wallet exists on it
- (BOOL)noWallet
{
    
    return YES;
}

// true if this is a "watch only" wallet with no signing ability
- (BOOL)watchOnly
{
    return NO;
}

@end
