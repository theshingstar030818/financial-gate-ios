//
//  BRWelcomeViewController.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-02.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRWelcomeADAViewController.h"
#import "BRRootViewController.h"
#import "BRWalletADAManager.h"
#import "BREventManager.h"


@interface BRWelcomeADAViewController ()

@property (nonatomic, assign) BOOL hasAppeared, animating;
@property (nonatomic, strong) id foregroundObserver, backgroundObserver;
@property (nonatomic, strong) UINavigationController *seedNav;

@property (nonatomic, strong) IBOutlet UIView *paralax, *wallpaper;
@property (nonatomic, strong) IBOutlet UILabel *startLabel, *recoverLabel, *warningLabel;
@property (nonatomic, strong) IBOutlet UIButton *newwalletButton, *recoverButton, *generateButton, *showButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *logoXCenter, *walletXCenter, *restoreXCenter,
*paralaxXLeft, *wallpaperXLeft;

@end

@implementation BRWelcomeADAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.newwalletButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.recoverButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.foregroundObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self animateWallpaper];
                                                       }];
    self.backgroundObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           self.wallpaperXLeft.constant = 0;
                                                           [self.wallpaper.superview layoutIfNeeded];
                                                       }];
    
}

- (void)dealloc
{
    if (self.navigationController.delegate == self) self.navigationController.delegate = nil;
    if (self.foregroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.foregroundObserver];
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.newwalletButton.layer.cornerRadius = 10;
    self.newwalletButton.layer.borderWidth = 2;
    self.newwalletButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.recoverButton.layer.cornerRadius = 10;
    self.recoverButton.layer.borderWidth = 2;
    self.recoverButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.generateButton.layer.cornerRadius = 10;
    self.generateButton.layer.borderWidth = 2;
    self.generateButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.showButton.layer.cornerRadius = 10;
    self.showButton.layer.borderWidth = 2;
    self.showButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    if (self.hasAppeared) {
        self.logoXCenter.constant = self.view.frame.size.width;
        self.navigationItem.titleView.hidden = NO;
    }
    else {
        self.walletXCenter.constant = -self.view.frame.size.width;
        self.restoreXCenter.constant = -self.view.frame.size.width;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [BREventManager saveEvent:@"welcome:shown"];
    
    dispatch_async(dispatch_get_main_queue(), ^{ // animation sometimes doesn't work if run directly in viewDidAppear
#if SNAPSHOT
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.navigationItem.titleView.hidden = NO;
        self.navigationItem.titleView.alpha = 1.0;
        self.logoXCenter.constant = self.view.frame.size.width;
        self.walletXCenter.constant = self.restoreXCenter.constant = 0.0;
        self.paralaxXLeft.constant = self.view.frame.size.width*PARALAX_RATIO;
        return;
#endif
        
//        if (! [BRWalletADAManager sharedInstance].noWallet) { // sanity check
//            [self.navigationController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
//        }
        
        if (! self.hasAppeared) {
            self.hasAppeared = YES;
            self.paralaxXLeft = [NSLayoutConstraint constraintWithItem:self.navigationController.view
                                                             attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.paralax
                                                             attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.navigationController.view insertSubview:self.paralax atIndex:0];
            [self.navigationController.view addConstraint:self.paralaxXLeft];
            [self.navigationController.view
             addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationController.view
                                                        attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.paralax
                                                        attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            //            self.navigationController.view.backgroundColor = self.paralax.backgroundColor;
            self.navigationController.view.clipsToBounds = YES;
            self.navigationController.view.backgroundColor = [UIColor clearColor];
            [self.navigationController.view layoutIfNeeded];
            self.logoXCenter.constant = self.view.frame.size.width;
            self.walletXCenter.constant = 0.0;
            self.restoreXCenter.constant = 0.0;
            //            self.paralaxXLeft.constant = self.view.frame.size.width*PARALAX_RATIO;
            self.navigationItem.titleView.hidden = NO;
            self.navigationItem.titleView.alpha = 0.0;
            
            [UIView animateWithDuration:0.35 delay:1.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseOut animations:^{
                                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                                    self.navigationItem.titleView.alpha = 1.0;
                                    [self.navigationController.view layoutIfNeeded];
                                } completion:nil];
        }
        
        [self animateWallpaper];
    });
}

- (IBAction)start:(id)sender
{
    NSLog(@"start ADA Wallet");
}

- (IBAction)recover:(id)sender
{
    NSLog(@"recover ADA Wallet");
}

- (IBAction)generate:(id)sender
{
    NSLog(@"generate ADA Wallet");
}

- (IBAction)show:(id)sender
{
    NSLog(@"show ADA Wallet");
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *v = transitionContext.containerView;
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey],
    *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    to.view.center = CGPointMake(v.frame.size.width*(to == self ? -1 : 3)/2.0, to.view.center.y);
    [v addSubview:to.view];
    [v layoutIfNeeded];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.8
          initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
              to.view.center = from.view.center;
              from.view.center = CGPointMake(v.frame.size.width*(to == self ? 3 : -1)/2.0, from.view.center.y);
          } completion:^(BOOL finished) {
              if (to == self) [from.view removeFromSuperview];
              [transitionContext completeTransition:YES];
          }];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (void)animateWallpaper
{
    if (self.animating) return;
    self.animating = YES;
    
    self.wallpaperXLeft.constant = -240.0;
    
    [UIView animateWithDuration:30.0 delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         [self.wallpaper.superview layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.animating = NO;
                     }];
}

@end
