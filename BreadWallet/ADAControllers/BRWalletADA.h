//
//  BRWalletADA.h == CWallet
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-02.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRWalletADA_h
#define BRWalletADA_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BRWalletADA : NSObject

@property (nonatomic, assign) NSString* cwId;
@property (nonatomic, assign) NSString* cwMeta;
@property (nonatomic, assign) uint64_t cwAccountsNumber;
@property (nonatomic, assign) uint64_t cwAmount;
@property (nonatomic, assign) BOOL cwHasPassphrase;
@property (nonatomic, assign) uint64_t cwPassphraseLU;

@end

#endif /* BRWalletADA_h */
