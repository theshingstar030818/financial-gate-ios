//
//  BRWalletETH.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-09.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRWalletETH_h
#define BRWalletETH_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BRWalletETH : NSObject

@property (nonatomic, assign) uint64_t balance;
@property (nonatomic, readonly) NSString * _Nullable receiveAddress;
@property (nonatomic, readonly) NSString * _Nullable changeAddress;
@property (nonatomic, readonly) NSSet * _Nonnull allReceiveAddresses;
@property (nonatomic, readonly) NSSet * _Nonnull allChangeAddresses;
@property (nonatomic, readonly) NSArray * _Nonnull unspentOutputs;
@property (nonatomic, readonly) NSArray * _Nonnull recentTransactions;
@property (nonatomic, readonly) NSArray * _Nonnull allTransactions;
@property (nonatomic, readonly) uint64_t totalSent;
@property (nonatomic, readonly) uint64_t totalReceived;
@property (nonatomic, assign) uint64_t feePerKb;
@property (nonatomic, readonly) uint64_t minOutputAmount;
@property (nonatomic, readonly) uint64_t maxOutputAmount;

@end

#endif /* BRWalletETH_h */
