//
//  BRWalletETHManager.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-02.
//

#import <Foundation/Foundation.h>

#import "Wallet.h"
#import "Reachability.h"
#import "BRWalletETHManager.h"




@interface BRWalletETHManager()

@property (nonatomic, strong) Wallet *wallet;
@property (nonatomic, strong) Reachability *reachability;


@end

@implementation BRWalletETHManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    
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
