//
//  BRWalletADAManager.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-02.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRWalletADAManager_h
#define BRWalletADAManager_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BRWalletADA.h"

@interface BRWalletADAManager : NSObject<UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, readonly) BRWalletADA * _Nullable wallet;
@property (nonatomic, readonly) BOOL noWallet; // true if keychain is available and we know that no wallet exists on it

+ (instancetype _Nullable)sharedInstance;

- (NSString * _Nullable)generateRandomSeed; // generates a random seed, saves to keychain and returns the seedPhrase
- (NSData * _Nullable)seedWithPrompt:(NSString * _Nullable)authprompt forAmount:(uint64_t)amount;//auth user,return seed
- (NSString * _Nullable)seedPhraseWithPrompt:(NSString * _Nullable)authprompt; // authenticates user, returns seedPhrase
- (BOOL)authenticateWithPrompt:(NSString * _Nullable)authprompt andTouchId:(BOOL)touchId; // prompt user to authenticate
- (BOOL)setPin; // prompts the user to set or change wallet pin and returns true if the pin was successfully set

@end

#endif /* BRWalletADAManager_h */
