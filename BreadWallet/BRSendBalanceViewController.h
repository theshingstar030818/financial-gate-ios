//
//  BRSendBalanceViewController.h
//  BreadWallet
//
//  Created by Mac on 8/24/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BRPaymentRequest.h"

@class BRSendBalanceViewController;

@protocol BRSendBalanceViewControllerDelegate <NSObject>
@required

- (void)sendBalanceViewController:(BRSendBalanceViewController *)sendBalanceViewController request:(BRPaymentProtocolRequest *)request amount:(uint64_t)amount;
- (void)sendBalanceViewController:(BRSendBalanceViewController *)sendBalanceViewController confirmRequest:(BRPaymentRequest *)request amount:(uint64_t)amount;

@end

@interface BRSendBalanceViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) id<BRSendBalanceViewControllerDelegate> delegate;

@end
