//
//  BRWalletETHManager.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-02.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRWalletETHManager_h
#define BRWalletETHManager_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Wallet.h"

@interface BRWalletETHManager : NSObject<UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, readonly) Wallet * _Nullable wallet;
@property (nonatomic, readonly) BOOL noWallet; // true if keychain is available and we know that no wallet exists on it
+ (instancetype _Nullable)sharedInstance;



@end

#endif /* BRWalletETHManager_h */
