//
//  BRSendADAViewController.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-11-28.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#ifndef BRSendADAViewController_h
#define BRSendADAViewController_h


#endif /* BRSendADAViewController_h */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "BRAmountViewController.h"
//#import "BRSendBalanceViewController.h"

@interface BRSendADAViewController : UIViewController <UIAlertViewDelegate, UITextViewDelegate,
AVCaptureMetadataOutputObjectsDelegate, UIViewControllerTransitioningDelegate,
UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) IBOutlet UIPageViewController *pageViewController;
@property (nonatomic, strong) IBOutlet BRSendADAViewController *sendViewController;

//- (IBAction)tip:(id)sender;
//
//- (void)handleURL:(NSURL *)url;
//- (void)handleFile:(NSData *)file;
//- (void)updateClipboardText;

@end
