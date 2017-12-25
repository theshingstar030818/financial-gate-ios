//
//  BRBitcoinATM.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-25.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRBitcoinATM.h"

#import "BRAppDelegate.h"
#import "BRBubbleView.h"
#import "BRBouncyBurgerButton.h"
#import "BRPeerManager.h"
#import "BRWalletManager.h"
#import "BRPaymentRequest.h"
#import "UIImage+Utils.h"
#import "BREventManager.h"
#import "Reachability.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <sys/stat.h>
#import <mach-o/dyld.h>

@interface BRBitcoinATM : UITableViewController <UIAlertViewDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>


@end

