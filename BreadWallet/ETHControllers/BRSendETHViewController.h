//
//  BRSendADAViewController.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-11-28.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRSendETHViewController_h
#define BRSendETHViewController_h

#endif /* BRSendETHViewController_h */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Wallet.h"


@interface BRSendETHViewController : UIViewController <UIAlertViewDelegate, UITextViewDelegate,
AVCaptureMetadataOutputObjectsDelegate, UIViewControllerTransitioningDelegate,
UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) IBOutlet UIPageViewController *pageViewController;
@property (nonatomic, strong) IBOutlet BRSendETHViewController *sendViewController;

@end
