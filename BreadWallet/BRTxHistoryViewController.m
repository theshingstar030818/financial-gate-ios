//
//  BRTxHistoryViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 6/11/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

// Updated by Farrukh Askari <farrukh.askari01@gmail.com> on 3:22 PM 17/4/17.

#import "BRTxHistoryViewController.h"
#import "BRRootViewController.h"
#import "BRSettingsViewController.h"
#import "BRTxDetailViewController.h"
#import "BRSeedViewController.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "UIImage+Utils.h"
#import "BREventConfirmView.h"
#import "BREventManager.h"
#import "FinancialGate-Swift.h"
#import <WebKit/WebKit.h>

#define TRANSACTION_CELL_HEIGHT 75

static NSString *dateFormat(NSString *template)
{
    NSString *format = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    
    format = [format stringByReplacingOccurrencesOfString:@", " withString:@" "];
    format = [format stringByReplacingOccurrencesOfString:@" a" withString:@"a"];
    format = [format stringByReplacingOccurrencesOfString:@"hh" withString:@"h"];
    format = [format stringByReplacingOccurrencesOfString:@" ha" withString:@"@ha"];
    format = [format stringByReplacingOccurrencesOfString:@"HH" withString:@"H"];
    format = [format stringByReplacingOccurrencesOfString:@"H '" withString:@"H'"];
    format = [format stringByReplacingOccurrencesOfString:@"H " withString:@"H'h' "];
    format = [format stringByReplacingOccurrencesOfString:@"H" withString:@"H'h'"
              options:NSBackwardsSearch|NSAnchoredSearch range:NSMakeRange(0, format.length)];
    return format;
}

@interface BRTxHistoryViewController ()

@property (nonatomic, strong) IBOutlet UIView *logo;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *lock;

@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, assign) BOOL moreTx;
@property (nonatomic, strong) NSMutableDictionary *txDates;
@property (nonatomic, strong) id backgroundObserver, balanceObserver, txStatusObserver;
@property (nonatomic, strong) id syncStartedObserver, syncFinishedObserver, syncFailedObserver;
@property (nonatomic, strong) UIImageView *wallpaper;
@property (nonatomic, strong) BRWebViewController *buyController;

@end

@implementation BRTxHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.txDates = [NSMutableDictionary dictionary];
    self.wallpaper = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
    self.wallpaper.image = [UIImage imageNamed:@"wallpaper-default"];
    self.wallpaper.contentMode = UIViewContentModeBottomLeft;
    self.wallpaper.clipsToBounds = YES;
    self.wallpaper.center = CGPointMake(self.wallpaper.frame.size.width/2,
                                        self.navigationController.view.frame.size.height -
                                        self.wallpaper.frame.size.height/2);
    [self.navigationController.view insertSubview:self.wallpaper atIndex:0];
    self.navigationController.delegate = self;
    self.moreTx = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
#if SNAPSHOT
    BRTransaction *tx = [[BRTransaction alloc] initWithInputHashes:@[uint256_obj(UINT256_ZERO)] inputIndexes:@[@(0)]
                                                      inputScripts:@[[NSData data]] outputAddresses:@[@""] outputAmounts:@[@(0)]];
    
    manager.localCurrencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.moreTx = YES;
    manager.didAuthenticate = YES;
    [self unlock:nil];
    tx.txHash = UINT256_ZERO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.transactions = @[tx, tx, tx, tx, tx, tx];
        [self.tableView reloadData];
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@)", [manager stringForAmount:42980000],
                                     [manager localCurrencyStringForAmount:42980000]];
    });

    return;
#endif
    
    if (! manager.didAuthenticate) {
        [self performSelector:@selector(more:) withObject:self.tableView afterDelay:0.0];
    }
    else [self unlock:nil];

    if (! self.backgroundObserver) {
        self.backgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                    object:nil queue:nil usingBlock:^(NSNotification *note) {
            self.moreTx = YES;
            self.transactions = manager.wallet.allTransactions;
            [self.tableView reloadData];
            self.navigationItem.titleView = self.logo;
            self.navigationItem.rightBarButtonItem = self.lock;
        }];
    }

    if (! self.balanceObserver) {
        self.balanceObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil
                                                                                  queue:nil usingBlock:^(NSNotification *note) {
            BRTransaction *tx = self.transactions.firstObject;

            self.transactions = manager.wallet.allTransactions;

            if (! [self.navigationItem.title isEqual:NSLocalizedString(@"syncing...", nil)]) {
                if (! manager.didAuthenticate) self.navigationItem.titleView = self.logo;
            }

            if (self.transactions.firstObject != tx) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else [self.tableView reloadData];
        }];
    }

    if (! self.txStatusObserver) {
        self.txStatusObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                                                   queue:nil usingBlock:^(NSNotification *note) {
            self.transactions = manager.wallet.allTransactions;
            [self.tableView reloadData];
        }];
    }
    
    if (! self.syncStartedObserver) {
        self.syncStartedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncStartedNotification object:nil
                                                                                      queue:nil usingBlock:^(NSNotification *note) {
        if ([[BRPeerManager sharedInstance] timestampForBlockHeight:[BRPeerManager sharedInstance].lastBlockHeight] + 60*60*24*7 <
            [NSDate timeIntervalSinceReferenceDate] && manager.seedCreationTime + 60*60*24 < [NSDate timeIntervalSinceReferenceDate]) {
            }
        }];
    }
    
    if (! self.syncFinishedObserver) {
        self.syncFinishedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
                                                                                       queue:nil usingBlock:^(NSNotification *note) {
            if (! manager.didAuthenticate) self.navigationItem.titleView = self.logo;
        }];
    }
    
    if (! self.syncFailedObserver) {
        self.syncFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
                                                                                     queue:nil usingBlock:^(NSNotification *note) {
            if (! manager.didAuthenticate) self.navigationItem.titleView = self.logo;
        }];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.buyController preload];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"has_alerted_buy_bitcoin"] == NO &&
        [WKWebView class] && [[BRAPIClient sharedClient] featureEnabled:BRFeatureFlagsBuyBitcoin]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"has_alerted_buy_bitcoin"];
        [self showBuyAlert];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController || self.navigationController.isBeingDismissed) {
        //BUG: XXX this isn't triggered from start/recover new wallet
        if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
        self.backgroundObserver = nil;
        if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
        self.balanceObserver = nil;
        if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
        self.txStatusObserver = nil;
        if (self.syncStartedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncStartedObserver];
        self.syncStartedObserver = nil;
        if (self.syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFinishedObserver];
        self.syncFinishedObserver = nil;
        if (self.syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFailedObserver];
        self.syncFailedObserver = nil;
        self.wallpaper.clipsToBounds = YES;
        
        self.buyController = nil;
    }

    [super viewWillDisappear:animated];
}

- (void)dealloc {
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
    if (self.syncStartedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncStartedObserver];
    if (self.syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFinishedObserver];
    if (self.syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFailedObserver];
}

- (BRWebViewController *)buyController {
    if (_buyController) {
        return _buyController;
    }
    if ([WKWebView class] && [[BRAPIClient sharedClient] featureEnabled:BRFeatureFlagsBuyBitcoin]) { // only available on iOS 8 and above
#if DEBUG || TESTFLIGHT
        _buyController = [[BRWebViewController alloc] initWithBundleName:@"bread-buy-staging" mountPoint:@"/buy"];
        //        self.buyController.debugEndpoint = @"http://localhost:8080";
#else
        _buyController = [[BRWebViewController alloc] initWithBundleName:@"bread-buy" mountPoint:@"/buy"];
#endif
        [_buyController startServer];
        [_buyController preload];
    }
    return _buyController;
}

- (uint32_t)blockHeight {
    static uint32_t height = 0;
    uint32_t h = [BRPeerManager sharedInstance].lastBlockHeight;
    
    if (h > height) height = h;
    return height;
}

- (void)setTransactions:(NSArray *)transactions {
    uint32_t height = self.blockHeight;
    
    if (! [BRWalletManager sharedInstance].didAuthenticate &&
        [self.navigationItem.title isEqual:NSLocalizedString(@"syncing...", nil)]) {
        _transactions = @[];
        NSLog(@"TxH: %long", transactions.count);
        if (transactions.count > 0) self.moreTx = YES;
    }
    else {
        NSLog(@"TxH: %long", transactions.count);
        if (transactions.count <= 5) self.moreTx = NO;
        _transactions = (self.moreTx) ? [transactions subarrayWithRange:NSMakeRange(0, transactions.count)] : [transactions copy];
    
        if (! [BRWalletManager sharedInstance].didAuthenticate) {
            for (BRTransaction *tx in _transactions) {
                if (tx.blockHeight == TX_UNCONFIRMED || (tx.blockHeight > height - 10 && tx.blockHeight <= height)) continue;
                // else
                _transactions = [_transactions subarrayWithRange:NSMakeRange(0, [_transactions indexOfObject:tx])];
                self.moreTx = YES;
                break;
            }
        }
    }
}

- (void)setBackgroundForCell:(UITableViewCell *)cell tableView:(UITableView *)tableView indexPath:(NSIndexPath *)path {
    [cell viewWithTag:100].hidden = (path.row > 0);
    [cell viewWithTag:101].hidden = (path.row + 1 < [self tableView:tableView numberOfRowsInSection:path.section]);
}

- (NSString *)dateForTx:(BRTransaction *)tx {
    static NSDateFormatter *monthDayHourFormatter = nil;
    static NSDateFormatter *yearMonthDayHourFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{ // BUG: need to watch for NSCurrentLocaleDidChangeNotification
        monthDayHourFormatter = [NSDateFormatter new];
        monthDayHourFormatter.dateFormat = dateFormat(@"Mdja");
        yearMonthDayHourFormatter = [NSDateFormatter new];
        yearMonthDayHourFormatter.dateFormat = dateFormat(@"yyMdja");
    });
    
    NSString *date = self.txDates[uint256_obj(tx.txHash)];
    NSTimeInterval now = [[BRPeerManager sharedInstance] timestampForBlockHeight:TX_UNCONFIRMED];
    NSTimeInterval year = [NSDate timeIntervalSinceReferenceDate] - 364*24*60*60;

    if (date) return date;

    NSTimeInterval txTime = (tx.timestamp > 1) ? tx.timestamp : now;
    NSDateFormatter *desiredFormatter = (txTime > year) ? monthDayHourFormatter : yearMonthDayHourFormatter;
    
    date = [desiredFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:txTime]];
    date = [date stringByReplacingOccurrencesOfString:@"am" withString:@"a"];
    date = [date stringByReplacingOccurrencesOfString:@"pm" withString:@"p"];
    date = [date stringByReplacingOccurrencesOfString:@"AM" withString:@"a"];
    date = [date stringByReplacingOccurrencesOfString:@"PM" withString:@"p"];
    date = [date stringByReplacingOccurrencesOfString:@"a.m." withString:@"a"];
    date = [date stringByReplacingOccurrencesOfString:@"p.m." withString:@"p"];
    date = [date stringByReplacingOccurrencesOfString:@"A.M." withString:@"a"];
    date = [date stringByReplacingOccurrencesOfString:@"P.M." withString:@"p"];
    if (tx.blockHeight != TX_UNCONFIRMED) self.txDates[uint256_obj(tx.txHash)] = date;
    return date;
}

// MARK: - IBAction

- (IBAction)done:(id)sender {
    [BREventManager saveEvent:@"tx_history:dismiss"];
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)unlock:(id)sender {
    BRWalletManager *manager = [BRWalletManager sharedInstance];

    if (sender) [BREventManager saveEvent:@"tx_history:unlock"];
    //if (! manager.didAuthenticate && ! [manager authenticateWithPrompt:nil andTouchId:YES]) return;
    if (sender) [BREventManager saveEvent:@"tx_history:unlock_success"];
    
    [self.navigationItem setRightBarButtonItem:nil animated:(sender) ? YES : NO];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.transactions = manager.wallet.allTransactions;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sender && self.transactions.count > 0) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else [self.tableView reloadData];
        });
    });
}

- (IBAction)showTx:(id)sender {
    [BREventManager saveEvent:@"tx_history:show_tx"];
    BRTxDetailViewController *detailController
        = [self.storyboard instantiateViewControllerWithIdentifier:@"TxDetailViewController"];
    detailController.transaction = sender;
    detailController.txDateString = [self dateForTx:sender];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (IBAction)more:(id)sender {
    [BREventManager saveEvent:@"tx_history:more"];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSUInteger txCount = self.transactions.count;
    
    if (! manager.didAuthenticate) {
        [self unlock:sender];
        return;
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:txCount inSection:0]]
     withRowAnimation:UITableViewRowAnimationFade];
    self.moreTx = NO;
    self.transactions = manager.wallet.allTransactions;
    
    NSMutableArray *transactions = [NSMutableArray arrayWithCapacity:self.transactions.count];
    
    while (txCount == 0 || txCount < self.transactions.count) {
        [transactions addObject:[NSIndexPath indexPathForRow:txCount++ inSection:0]];
    }
    
    [self.tableView insertRowsAtIndexPaths:transactions withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)showBuyAlert {
    // grab a blurred image for the background
    UIGraphicsBeginImageContext(self.navigationController.view.bounds.size);
    [self.navigationController.view drawViewHierarchyInRect:self.navigationController.view.bounds
                                         afterScreenUpdates:NO];
    UIImage *bgImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *blurredBgImg = [bgImg blurWithRadius:3];
}

- (void)showBuy {
    [self presentViewController:self.buyController animated:YES completion:nil];
}

- (NSString *)updateBalance:(uint64_t)amount {
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    manager.format.maximumFractionDigits = 8;
    NSString *stringWithoutSpaces = [[manager stringForAmount: amount]
                                     stringByReplacingOccurrencesOfString:@"ƀ" withString:@""];
    
    stringWithoutSpaces = [stringWithoutSpaces stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    CGFloat btcAmount = [stringWithoutSpaces floatValue];
    
    NSString *btcAmountStr = [NSString stringWithFormat:@"BTC %.8f",btcAmount];
    
    return btcAmountStr;
}

#pragma mark: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    if (! manager.didAuthenticate) {
        return 0;
    } else {
        if (self.transactions.count == 0) return 1;
        return (self.moreTx) ? self.transactions.count : self.transactions.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *noTxIdent = @"NoTxCell", *transactionIdent = @"TransactionCell";
    UITableViewCell *cell = nil;
    UILabel *textLabel, *unconfirmedLabel, *sentLabel, *localCurrencyLabel, *balanceLabel, *localBalanceLabel, *detailTextLabel;
    BRWalletManager *manager = [BRWalletManager sharedInstance];

    if (self.transactions.count > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:transactionIdent];
        textLabel = (id)[cell viewWithTag:1];
        detailTextLabel = (id)[cell viewWithTag:2];
        unconfirmedLabel = (id)[cell viewWithTag:3];
        localCurrencyLabel = (id)[cell viewWithTag:5];
        sentLabel = (id)[cell viewWithTag:6];
        balanceLabel = (id)[cell viewWithTag:7];
        localBalanceLabel = (id)[cell viewWithTag:8];

        BRTransaction *tx = self.transactions[indexPath.row];
        uint64_t received = [manager.wallet amountReceivedFromTransaction:tx],
                 sent = [manager.wallet amountSentByTransaction:tx],
                 balance = [manager.wallet balanceAfterTransaction:tx];
        uint32_t blockHeight = self.blockHeight;
        uint32_t confirms = (tx.blockHeight > blockHeight) ? 0 : (blockHeight - tx.blockHeight) + 1;

#if SNAPSHOT
        received = [@[@(0), @(0), @(54000000), @(0), @(0), @(93000000)][indexPath.row] longLongValue];
        sent = [@[@(1010000), @(10010000), @(0), @(82990000), @(10010000), @(0)][indexPath.row] longLongValue];
        balance = [@[@(42980000), @(43990000), @(54000000), @(0), @(82990000), @(93000000)][indexPath.row] longLongValue];
        [self.txDates removeAllObjects];
        tx.timestamp = [NSDate timeIntervalSinceReferenceDate] - indexPath.row*100000;
        confirms = 6;
#endif
        textLabel.textColor = [UIColor lightGrayColor];
        sentLabel.hidden = YES;
        unconfirmedLabel.hidden = NO;
        unconfirmedLabel.backgroundColor = [UIColor lightGrayColor];
        detailTextLabel.text = [self dateForTx:tx];
        balanceLabel.text = (manager.didAuthenticate) ? [self updateBalance:balance] : nil;
        localBalanceLabel.text = (manager.didAuthenticate) ?
        [NSString stringWithFormat:@"(%@)", [manager localCurrencyStringForAmount:balance]] : nil;

        if (confirms == 0 && ! [manager.wallet transactionIsValid:tx]) {
            unconfirmedLabel.text = NSLocalizedString(@"INVALID", nil);
            unconfirmedLabel.backgroundColor = [UIColor redColor];
            balanceLabel.text = localBalanceLabel.text = nil;
        }
        else if (confirms == 0 && [manager.wallet transactionIsPending:tx]) {
            unconfirmedLabel.text = NSLocalizedString(@"pending", nil);
            unconfirmedLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
            textLabel.textColor = [UIColor grayColor];
            balanceLabel.text = localBalanceLabel.text = nil;
        }
        else if (confirms == 0 && ! [manager.wallet transactionIsVerified:tx]) {
            unconfirmedLabel.text = NSLocalizedString(@"unverified", nil);
        }
        else if (confirms < 6) {
            if (confirms == 0) unconfirmedLabel.text = NSLocalizedString(@"0 confirmations", nil);
            else if (confirms == 1) unconfirmedLabel.text = NSLocalizedString(@"1 confirmation", nil);
            else unconfirmedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d confirmations", nil), (int)confirms];
        }
        else {
            unconfirmedLabel.text = nil;
            unconfirmedLabel.hidden = YES;
            sentLabel.hidden = NO;
        }
                
        if (sent > 0 && received == sent) {
            textLabel.text = [self updateBalance:sent];
            localCurrencyLabel.text = [NSString stringWithFormat:@"(%@)", [manager localCurrencyStringForAmount:sent]];
            sentLabel.text = NSLocalizedString(@"moved", nil);
            sentLabel.textColor = [UIColor blackColor];
        }
        else if (sent > 0) {
            textLabel.text = [self updateBalance:received - sent];
            localCurrencyLabel.text = [NSString stringWithFormat:@"(%@)", [manager localCurrencyStringForAmount:received - sent]];
            sentLabel.text = NSLocalizedString(@"sent", nil);
            sentLabel.textColor = [UIColor colorWithRed:1.0 green:0.33 blue:0.33 alpha:1.0];
        }
        else {
            textLabel.text = [self updateBalance:received];
            localCurrencyLabel.text = [NSString stringWithFormat:@"(%@)", [manager localCurrencyStringForAmount:received]];
            sentLabel.text = NSLocalizedString(@"received", nil);
            sentLabel.textColor = [UIColor colorWithRed:0.0 green:0.75 blue:0.0 alpha:1.0];
        }

        if (! unconfirmedLabel.hidden) {
            unconfirmedLabel.layer.cornerRadius = 3.0;
            unconfirmedLabel.text = [unconfirmedLabel.text stringByAppendingString:@"  "];
        }
        else {
            sentLabel.layer.cornerRadius = 3.0;
            sentLabel.layer.borderWidth = 0.5;
            sentLabel.text = [sentLabel.text stringByAppendingString:@"  "];
            sentLabel.layer.borderColor = sentLabel.textColor.CGColor;
            sentLabel.highlightedTextColor = sentLabel.textColor;
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:noTxIdent];
    }
    
    [self setBackgroundForCell:cell tableView:tableView indexPath:indexPath];
    
    return cell;
}


#pragma mark: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.moreTx && indexPath.row >= self.transactions.count) ? 44.0 : TRANSACTION_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];

    if (sectionTitle.length == 0) return 22.0;

    CGRect r = [sectionTitle boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20.0, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:13]} context:nil];
    
    return r.size.height + 22.0 + 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, [self tableView:tableView heightForHeaderInSection:section])];
    UILabel *l = [UILabel new];
    CGRect r = CGRectMake(15.0, 0.0, v.frame.size.width - 20.0, v.frame.size.height - 22.0);
    
    l.text = [self tableView:tableView titleForHeaderInSection:section];
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    l.textColor = [UIColor grayColor];
    l.shadowColor = [UIColor whiteColor];
    l.shadowOffset = CGSizeMake(0.0, 1.0);
    l.numberOfLines = 0;
    r.size.width = [l sizeThatFits:r.size].width;
    r.origin.x = (self.view.frame.size.width - r.size.width)/2;
    if (r.origin.x < 15.0) r.origin.x = 15.0;
    l.frame = r;
    v.backgroundColor = [UIColor clearColor];
    [v addSubview:l];

    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section + 1 == [self numberOfSectionsInTableView:tableView]) ? 22.0 : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, [self tableView:tableView heightForFooterInSection:section])];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.transactions.count > 0) {
        [self showTx:self.transactions[indexPath.row]]; // transaction details
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark: - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        return;
    }

    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:NSLocalizedString(@"show", nil)]) {
        BRSeedViewController *seedController = [self.storyboard instantiateViewControllerWithIdentifier:@"SeedViewController"];
        if (seedController.authSuccess) [self.navigationController pushViewController:seedController animated:YES];
    }    
}

@end
