//
//  BRMarketsViewController.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-18.

#import "BRMarketsViewController.h"
#import "BRRootViewController.h"
#import "BRSettingsViewController.h"
#import "BRCoinDetailViewController.h"
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
#import "Reachability.h"



#define COIN_MARKET_CAP_TRACKER     @"COIN_MARKET_CAP_TRACKER"
#define COIN_MARKET_CAP_TRACKER_TIME     @"COIN_MARKET_CAP_TRACKER_TIME"
#define COIN_MARKET_CAP_URL         @"https://api.coinmarketcap.com/v1/ticker/?"
#define COIN_MARKET_CAP_CONVERT     @"convert="
#define COIN_MARKET_CAP_LIMIT       @"limit="

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

@interface BRMarketsViewController ()

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) IBOutlet UIView *logo;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *lock;
@property (nonatomic, strong) NSArray *tickers;
@property (nonatomic, assign) BOOL moreTx, moreTickers;
@property (nonatomic, strong) NSMutableDictionary *txDates;
@property (nonatomic, strong) id backgroundObserver, balanceObserver, txStatusObserver;
@property (nonatomic, strong) id syncStartedObserver, syncFinishedObserver, syncFailedObserver;
@property (nonatomic, strong) UIImageView *wallpaper;
@property (nonatomic, strong) BRWebViewController *buyController;

@end

@implementation BRMarketsViewController

- (void)updateMarketsTicker
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMarketsTicker) object:nil];
    [self performSelector:@selector(updateMarketsTicker) withObject:nil afterDelay:60.0];
    [self loadMarketsTicker];
}

- (void)loadMarketsTicker
{
    if (self.reachability.currentReachabilityStatus == NotReachable) {
        return;
    }
    
    NSString *request_url = [[COIN_MARKET_CAP_URL stringByAppendingString:COIN_MARKET_CAP_LIMIT]stringByAppendingString:@"0"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request_url]
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSLog(@"%@", req.URL.absoluteString);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (error != nil) {
                                             NSLog(@"unable to fetch market tickers: %@", error);
                                             return;
                                         }
                                         NSArray *tickers = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                         self.tickers = tickers;
                                         [self saveMarketTracker:data];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (self.tickers.count > 0) {
                                                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                                             }else{
                                                 [self.tableView reloadData];
                                             }
                                         });
                                     }] resume];
}

- (void)saveMarketTracker:(NSData *)tickers
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:tickers] forKey:COIN_MARKET_CAP_TRACKER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)getMarketTracker
{
    NSArray *tickers;
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:COIN_MARKET_CAP_TRACKER];
    if (dataRepresentingSavedArray != nil)
    {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        tickers = [NSJSONSerialization JSONObjectWithData:oldSavedArray options:0 error:nil];
    }
    return tickers;
}

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
    self.reachability = [Reachability reachabilityForInternetConnection];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    self.navigationController.navigationItem.backBarButtonItem.enabled = YES;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    if (! manager.didAuthenticate) {
        [self performSelector:@selector(more:) withObject:self.tableView afterDelay:0.0];
    }
    else [self unlock:nil];
    
//    if (! self.backgroundObserver) {
//        self.backgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
//                                                                                    object:nil queue:nil usingBlock:^(NSNotification *note) {
//                                                                                        self.moreTx = YES;
//                                                                                        self.transactions = manager.wallet.allTransactions;
//                                                                                        [self.tableView reloadData];
//                                                                                        self.navigationItem.titleView = self.logo;
//                                                                                        self.navigationItem.rightBarButtonItem = self.lock;
//                                                                                    }];
//    }
    
//    if (! self.balanceObserver) {
//        self.balanceObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil
//                                                                                  queue:nil usingBlock:^(NSNotification *note) {
//                                                                                      BRTransaction *tx = self.transactions.firstObject;
//
//                                                                                      self.transactions = manager.wallet.allTransactions;
//
//                                                                                      if (! [self.navigationItem.title isEqual:NSLocalizedString(@"syncing...", nil)]) {
//                                                                                          if (! manager.didAuthenticate) self.navigationItem.titleView = self.logo;
//                                                                                      }
//
//                                                                                      if (self.transactions.firstObject != tx) {
//                                                                                          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//                                                                                      }
//                                                                                      else [self.tableView reloadData];
//                                                                                  }];
//    }
    
//    if (! self.txStatusObserver) {
//        self.txStatusObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
//                                                                                   queue:nil usingBlock:^(NSNotification *note) {
//                                                                                       self.transactions = manager.wallet.allTransactions;
//                                                                                       [self.tableView reloadData];
//                                                                                   }];
//    }
    
//    if (! self.syncStartedObserver) {
//        self.syncStartedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncStartedNotification object:nil
//                                                                                      queue:nil usingBlock:^(NSNotification *note) {
//                                                                                          if ([[BRPeerManager sharedInstance] timestampForBlockHeight:[BRPeerManager sharedInstance].lastBlockHeight] + 60*60*24*7 <
//                                                                                              [NSDate timeIntervalSinceReferenceDate] && manager.seedCreationTime + 60*60*24 < [NSDate timeIntervalSinceReferenceDate]) {
//                                                                                          }
//                                                                                      }];
//    }
    
//    if (! self.syncFinishedObserver) {
//        self.syncFinishedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
//                                                                                       queue:nil usingBlock:^(NSNotification *note) {
//                                                                                           if (! manager.didAuthenticate) self.navigationItem.titleView = self.logo;
//                                                                                       }];
//    }
    
//    if (! self.syncFailedObserver) {
//        self.syncFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
//                                                                                     queue:nil usingBlock:^(NSNotification *note) {
//                                                                                         if (! manager.didAuthenticate) self.navigationItem.titleView = self.logo;
//                                                                                     }];
//    }
    
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

- (void)setTickers:(NSArray *)tickers {
    _tickers = @[];
    NSLog(@"Tickers: %long", tickers.count);
    if (tickers.count <= 5) self.moreTickers = NO;
    _tickers = (self.moreTickers) ? [tickers subarrayWithRange:NSMakeRange(0, tickers.count)] : [tickers copy];
    if (! [BRWalletManager sharedInstance].didAuthenticate) {
        for (NSDictionary *ticker in _tickers) {
            _tickers = [_tickers subarrayWithRange:NSMakeRange(0, [_tickers indexOfObject:ticker])];
            self.moreTickers = YES;
            break;
        }
    }
}

- (void)setBackgroundForCell:(UITableViewCell *)cell tableView:(UITableView *)tableView indexPath:(NSIndexPath *)path {
    [cell viewWithTag:100].hidden = (path.row > 0);
    [cell viewWithTag:101].hidden = (path.row + 1 < [self tableView:tableView numberOfRowsInSection:path.section]);
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
    if (sender) [BREventManager saveEvent:@"markets:unlock"];
    
    //if (! manager.didAuthenticate && ! [manager authenticateWithPrompt:nil andTouchId:YES]) return;
    
    if (sender) [BREventManager saveEvent:@"markets:unlock_success"];
    
    [self.navigationItem setRightBarButtonItem:nil animated:(sender) ? YES : NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.tickers = [self getMarketTracker];
        [self updateMarketsTicker];
    });
}

- (IBAction)showTicker:(id)sender {
    [BREventManager saveEvent:@"markets:show_ticker"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CoinDetailViewStoryBoard"
                                                         bundle:nil];
    BRCoinDetailViewController *detailController
    = [storyboard instantiateViewControllerWithIdentifier:@"BRCoinDetailViewController"];
    detailController.coin = sender;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (IBAction)more:(id)sender {
    [BREventManager saveEvent:@"markets:more"];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSUInteger txCount = self.tickers.count;
    
    if (! manager.didAuthenticate) {
        [self unlock:sender];
        return;
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:txCount inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    self.moreTx = NO;
    self.tickers = manager.wallet.allTransactions;
    
    NSMutableArray *transactions = [NSMutableArray arrayWithCapacity:self.tickers.count];
    
    while (txCount == 0 || txCount < self.tickers.count) {
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
        if (self.tickers.count == 0) return 1;
        return (self.moreTx) ? self.tickers.count : self.tickers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *noTxIdent = @"NoTxCell", *transactionIdent = @"TransactionCell";
    
    UITableViewCell *cell = nil;
    
    UILabel *coidId, *coindName, *coinSymbol, *coinRank, *coinPrice_usd, *coinPrice_btc, *coin24h_volume_usd, *coinMarket_cap_usd, *coinAvailable_supply, *coinTotal_supply, *coinPercent_change_1h, *coinPercent_change_24h, *coinPercent_change_7d, *coinLast_updated;
    
    
    if(self.tickers.count>0){
        cell = [tableView dequeueReusableCellWithIdentifier:transactionIdent];
        coindName = (id)[cell viewWithTag:1];
        coinSymbol = (id)[cell viewWithTag:2];
        coinPercent_change_1h = (id)[cell viewWithTag:6];
        coinPercent_change_24h = (id)[cell viewWithTag:3];
        coinPercent_change_7d = (id)[cell viewWithTag:9];
        coinPrice_btc = (id)[cell viewWithTag:7];
        coinPrice_usd = (id)[cell viewWithTag:8];
        
        NSDictionary *ticker = self.tickers[indexPath.row];
        coindName.text = [ticker valueForKey:@"name"];
        coinSymbol.text = [ticker valueForKey:@"symbol"];
        NSString *cpc1h =[ticker valueForKey:@"percent_change_1h"];
        if(cpc1h==[NSNull null]) {
            cpc1h=@"0";
        }
        coinPercent_change_1h.text = [cpc1h stringByAppendingString: @"%"];
        if([cpc1h doubleValue]<0.0){
           coinPercent_change_1h.textColor = [UIColor redColor];
        }else{
            coinPercent_change_1h.textColor = [UIColor greenColor];
        }
        
        NSString *cpc24h =[ticker valueForKey:@"percent_change_24h"];
        if(cpc24h==[NSNull null]) {
            cpc24h=@"0";
        }
        coinPercent_change_24h.text = [cpc24h stringByAppendingString: @"%"];
        if([cpc24h doubleValue]<0.0){
            coinPercent_change_24h.textColor = [UIColor redColor];
        }else{
            coinPercent_change_24h.textColor = [UIColor greenColor];
        }

        NSString *cpc7d =[ticker valueForKey:@"percent_change_7d"];
        if(cpc7d==[NSNull null]) {
            cpc7d=@"0";
        }
        coinPercent_change_7d.text = [cpc7d stringByAppendingString: @"%"];
        if([cpc7d doubleValue]<0.0){
            coinPercent_change_7d.textColor = [UIColor redColor];
        }else{
            coinPercent_change_7d.textColor = [UIColor greenColor];
        }
        
        NSString *cpBTC = [ticker valueForKey:@"price_btc"];
        if([ticker valueForKey:@"price_btc"]==[NSNull null]) cpBTC=@"0.00000000";
        coinPrice_btc.text = [cpBTC stringByAppendingString: @" BTC"];
        
        NSString *cpUSD = [ticker valueForKey:@"price_usd"];
        if([ticker valueForKey:@"price_usd"]==[NSNull null]) cpUSD=@"0.00";
        
        coinPrice_usd.text = [@"$" stringByAppendingString: cpUSD];
        
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:noTxIdent];
    }
    
    [self setBackgroundForCell:cell tableView:tableView indexPath:indexPath];
    
    return cell;
}


#pragma mark: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.moreTx && indexPath.row >= self.tickers.count) ? 44.0 : TRANSACTION_CELL_HEIGHT;
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
    if (self.tickers.count > 0) {
        [self showTicker:self.tickers[indexPath.row]]; // tickers details
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

