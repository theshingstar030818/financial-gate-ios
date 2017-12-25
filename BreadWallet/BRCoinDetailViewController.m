
//
//  BRCoinDetailViewController.h
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-19.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRCoinDetailViewController.h"
#import "BRWalletManager.h"
#import "DrGraphs.h"
#import "Reachability.h"

#define COIN_CELL_HEIGHT 75
#define header_height 0

#define CHART_LINE 0
#define CHART_HORIZONTAL_STACK 1
#define CHART_PIE 2
#define CHART_BAR 3
#define CHART_CIRCULAR 4

@interface BRCoinDetailViewController ()<MultiLineGraphViewDataSource, MultiLineGraphViewDelegate, PieChartDataSource, PieChartDelegate, HorizontalStackBarChartDataSource, HorizontalStackBarChartDelegate, BarChartDataSource, BarChartDelegate, CircularChartDataSource, CircularChartDelegate>

@property (nonatomic, strong) NSDictionary *histMINData, *histHRData, *histDAYData;
@property (nonatomic, strong) NSArray *histMIN, *histHR, *histDAY;
@property (nonatomic, strong) NSMutableArray *xRange, *yRange;
@property (nonatomic, strong) id coinStatusObserver;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSString *apiCall, *limit, *tsym, *histoRangeString;
@property (nonatomic, strong) UITableViewCell *chartCell;
@property (nonatomic, strong) UITableView *chartTableView;

@property (nonatomic, strong) NSString *chartRequest;
@property (nonatomic, strong) UILabel *currentRangeChangePercentage;
@property (nonatomic, strong) UITableViewCell *currentRangeChangePercentageCell;
@property (nonatomic, strong) UIButton *lastCheckedButton;

@end

@implementation BRCoinDetailViewController

- (UITableViewCell *)initializeWithChartType:(ChartType)type :(UITableView*)tableView{
    UITableViewCell *cell;
    if (self) {
        self.chartType = type;
        cell = [self createGraph:tableView];
    }
    return cell;
}

- (NSString *)makeCoinCompareHistoRequestURL
{
    NSString *coinCompareRangeRequestURL = @"";
    
    return nil;
}

- (UITableViewCell *) createGraph:(UITableView*)tableView{
    UITableViewCell *cell;
    switch (self.chartType) {
        case ChartTypeLine:
            cell = [self createLineGraph:tableView];
            break;
//        case ChartTypeHorizontalStack:
//            [self createHorizontalStackChart];
//            break;
//        case ChartTypePie:
//            [self createPieChart];
//            break;
//        case ChartTypeBar:
//            [self createBarChart];
//            break;
//        case ChartTypeCircular:
//            [self createCircularChart];
//            break;
        default:
            break;
    }
    return cell;
}

- (IBAction)rangeChangeButton:(UIButton *)sender
{
    if(!_lastCheckedButton){
        _lastCheckedButton = sender;
        _lastCheckedButton.backgroundColor = [UIColor grayColor];
        _lastCheckedButton.highlighted = YES;
    }else{
        _lastCheckedButton.highlighted = NO;
        _lastCheckedButton = sender;
        _lastCheckedButton.highlighted = YES;
    }
    
    if(sender.tag == 41){
        NSLog(@"Today"); // 24 hr and Today
        _limit = @"24";
        _apiCall = @"histohour";
        self.histoRange = hours24;
        _histoRangeString = @"24hr ";
        _currentRangeChangePercentage.text = @"24hr";
    }else if(sender.tag == 42){
        NSLog(@"1 week");
        _limit = @"60";
        _apiCall = @"histominute";
        self.histoRange = oneWeek;
        _histoRangeString = @"1Week ";
        _currentRangeChangePercentage.text = @"1 Week";
    }else if(sender.tag == 43){
        NSLog(@"1 month");
        _limit = @"30";
        _apiCall = @"histoday";
        _histoRangeString = @"1 Month ";
        _currentRangeChangePercentage.text = @"1 Month";
        self.histoRange = oneMonth;
    }else if(sender.tag == 44){
        NSLog(@"3 months");
        _limit = @"90";
        _apiCall = @"histoday";
        _histoRangeString = @"3 Months ";
        _currentRangeChangePercentage.text = @"3 Months";
        self.histoRange = oneYear;
    }else if(sender.tag == 45){
        NSLog(@"1 year");
        _limit = @"30";
        _apiCall = @"histoday";
        self.histoRange = oneYear;
        _histoRangeString = @"1 Year ";
        _currentRangeChangePercentage.text = @"1 Year";
    }else if(sender.tag == 46){
        NSLog(@"All");
    }
    
    [self loadChartData:[[self tableView] dequeueReusableCellWithIdentifier:@"line_chart_cell"] :[self tableView]];
}

- (void)loadChartData:(UITableViewCell *)cell :(UITableView *)tableView
{

    //    if (self.reachability.currentReachabilityStatus == NotReachable) {
    //        return;
    //    }
    
    if(!cell){
        cell = _chartCell;
    }
    
    if(!tableView){
        _chartTableView = tableView;
    }
    
    if(self.histoRange == NULL){ // Today or 24 hour are same
        self.histoRange = hours24;
        _limit = @"24";
        _apiCall = @"histohour";
    }else if(self.histoRange == hours24){ // Today or 24 hour are same
        _limit = @"24";
        _apiCall = @"histohour";
        self.histoRange = hours24;
    }else if(self.histoRange == hour){  // Today or 24 hour are same
        _limit = @"60";
        _apiCall = @"histominute";
    }else if(self.histoRange == oneWeek){
        _limit = @"7";
        _apiCall = @"histoday";
    }else if(self.histoRange == oneMonth){
        _limit = @"30";
        _apiCall = @"histoday";
    }else if(self.histoRange == oneYear){
        _limit = @"365";
        _apiCall = @"histoday";
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *lcc = [manager localCurrencyCode];
    NSString *coinCode = [_coin valueForKey:@"symbol"];
    
    NSString *coinCompareRangeURL = [NSString stringWithFormat:@"https://min-api.cryptocompare.com/data/%@?fsym=%@&tsym=%@&limit=%@&aggregate=3&e=CCCAGG",_apiCall,coinCode,lcc,_limit];
    
    NSString *hwString = [@"https://min-api.cryptocompare.com/data/histohour?fsym=" stringByAppendingString:coinCode];
    hwString = [hwString stringByAppendingString:@"&tsym="];
    hwString = [hwString stringByAppendingString:lcc];
    hwString = [hwString stringByAppendingString:@"&limit=60&aggregate=3&e=CCCAGG"];
    
    NSLog(@"coinCompareRangeURL : %@", coinCompareRangeURL);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:coinCompareRangeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSLog(@"%@", req.URL.absoluteString);
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (error != nil) {
             NSLog(@"unable to fetch market tickers: %@", error);
             return;
         }
        _histHRData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        _histHR =[_histHRData valueForKey:@"Data"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.histHR.count > 0) {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [self.tableView reloadData];
            }
            double start = [[_histHR[0] valueForKey:@"close"] doubleValue];
            double end = [[_histHR[_histHR.count-1] valueForKey:@"close"] doubleValue];
            double percentChangeForRange = ((end - start)/start)*100;
            NSLog(@"percentChangeForRange : %f", percentChangeForRange);
            NSString *tmp = _currentRangeChangePercentage.text;
            _currentRangeChangePercentage.text = [NSString stringWithFormat:@"%@ %f%%", tmp, percentChangeForRange];
            _currentRangeChangePercentage.text = _currentRangeChangePercentage.text;
            if(percentChangeForRange > 0){
                _currentRangeChangePercentage.backgroundColor = [UIColor greenColor];
            }else{
                _currentRangeChangePercentage.backgroundColor = [UIColor redColor];
            }
        });
    }] resume];
}

#pragma Mark CreateLineGraph
- (UITableViewCell *)createLineGraph:(UITableView*)tableView{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"line_chart_cell"];
    UIView *graphView = (id)[cell viewWithTag:9];
    MultiLineGraphView *graph = [[MultiLineGraphView alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(cell), 200.0)];
    [graph setDelegate:self];
    [graph setShowLegend:NO];
    [graph setDataSource:self];
    [graph setLegendViewType:LegendTypeHorizontal];
    [graph setShowCustomMarkerView:TRUE];
    [graph drawGraph];
    [graphView addSubview:graph];
    return cell;
}

#pragma mark MultiLineGraphViewDataSource
- (NSInteger)numberOfLinesToBePlotted{
    return 1;
}

- (LineDrawingType)typeOfLineToBeDrawnWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return LineDefault;
            break;
        case 1:
            return LineDefault;
            break;
        case 2:
            return LineDefault;
            break;
        case 3:
            return LineParallelXAxis;
            break;
        case 4:
            return LineParallelYAxis;
            break;
        default:
            break;
    }
    return LineDefault;
}

- (UIColor *)colorForTheLineWithLineNumber:(NSInteger)lineNumber{
    return [self chartColor];
}

- (UIColor *)chartColor
{
    if(_apiCall == @"histohour"  && self.histoRange == hours24){
        NSString *cpc24h =[_coin valueForKey:@"percent_change_24h"];
        if(cpc24h==[NSNull null]) {
            cpc24h=@"0";
        }
        
        if([cpc24h doubleValue]<0.0){
            return [UIColor redColor];
        }else{
            return [UIColor greenColor];
        }
    }else{
        return [UIColor greenColor];
    }
}


- (CGFloat)widthForTheLineWithLineNumber:(NSInteger)lineNumber{
    return 1;
}

- (NSString *)nameForTheLineWithLineNumber:(NSInteger)lineNumber{
//    return [NSString stringWithFormat:@"BTC %ld",(long)lineNumber];
    return @"";
}

- (BOOL)shouldFillGraphWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return true;
            break;
        case 1:
            return true;
            break;
        case 2:
            return false;
            break;
        case 3:
            return false;
            break;
        case 4:
            return true;
            break;
        default:
            break;
    }
    return false;
}

- (BOOL)shouldDrawPointsWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return false;
            break;
        case 1:
            return false;
            break;
        case 2:
            return false;
            break;
        case 3:
            return false;
            break;
        case 4:
            return false;
            break;
        default:
            break;
    }
    return false;
}

- (NSMutableArray *)dataForYAxisWithLineNumber:(NSInteger)lineNumber {
    switch (lineNumber) {
        case 0:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if(_histHR.count>0){
                for (int i = 0; i <= _histHR.count-1; i++) {
                    [array addObject:[_histHR[i] valueForKey:@"close"]];
                }
            }else{
                for (int i = 21; i <= 21; i++) {
                    [array addObject:[NSString stringWithFormat:@"%d", i]];
                }
            }
            _yRange = [array copy];
            return array;
        }
            break;
        case 1:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < 10; i++) {
                [array addObject:[NSNumber numberWithLong:random() % 100]];
            }
            return array;
        }
            break;
        case 2:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < 30; i++) {
                [array addObject:[NSNumber numberWithLong:random() % 50]];
            }
            return array;
        }
            break;
        case 3:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:[NSNumber numberWithLong:random() % 100]];
            [array addObject:[NSNumber numberWithLong:random() % 100]];
            return array;
        }
            break;
        case 4:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            return array;
        }
            break;
        default:
            break;
    }
    return [[NSMutableArray alloc] init];
}

- (NSMutableArray *)dataForXAxisWithLineNumber:(NSInteger)lineNumber {
    switch (lineNumber) {
        case 0:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if(_histHR.count>0){
                for (int i = 0; i <= _histHR.count-1; i++) {
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_histHR[i] valueForKey:@"time"] doubleValue]];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"d-M hh a"];
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    
                    [array addObject:[NSString stringWithFormat:@"%@", formattedDateString]];
                }
            }else{
                for (int i = 21; i <= 21; i++) {
                    [array addObject:[NSString stringWithFormat:@"%d", i]];
                }
            }
            _xRange = [array copy];
            return array;
        }
            break;
        case 1:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 1; i <= 30; i++) {
                [array addObject:[NSString stringWithFormat:@"%d Jun", i]];
            }
            return array;
        }
            break;
        case 2:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 1; i <= 30; i++) {
                [array addObject:[NSString stringWithFormat:@"%d Jun", i]];
            }
            return array;
        }
            break;
        case 3:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 1; i <= 30; i+=10) {
                [array addObject:[NSString stringWithFormat:@"%d Jun", i]];
            }
            return array;
        }
            break;
        case 4:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:@"6 Jun"];
            [array addObject:@"28 Jun"];
            return array;
        }
            break;
        default:
            break;
    }
    return [[NSMutableArray alloc] init];
}

- (UIView *)customViewForLineChartTouchWithXValue:(id)xValue andYValue:(id)yValue{
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *lcc = [manager localCurrencyCode];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[self chartColor]];
    [view.layer setCornerRadius:4.0F];
    [view.layer setBorderWidth:1.0F];
    [view.layer setBorderColor:[[UIColor clearColor] CGColor]];
    [view.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    [view.layer setShadowRadius:2.0F];
    [view.layer setShadowOpacity:0.3F];
    
    CGFloat y = 0;
    CGFloat width = 0;
    for (int i = 0; i < 2 ; i++) {
        if(i==0){
            UILabel *label = [[UILabel alloc] init];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:[NSString stringWithFormat:@"price = %@ %@", lcc, yValue]];
            [label setFrame:CGRectMake(0, y, 200, 30)];
            [view addSubview:label];
            width = WIDTH(label);
            y = BOTTOM(label);
        }else{
            UILabel *label = [[UILabel alloc] init];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:[NSString stringWithFormat:@"date = %@", xValue]];
            [label setFrame:CGRectMake(0, y, 200, 30)];
            [view addSubview:label];
            width = WIDTH(label);
            y = BOTTOM(label);
        }
        
    }
    
    [view setFrame:CGRectMake(0, 0, width, y)];
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadChartData:[[self tableView] dequeueReusableCellWithIdentifier:@"line_chart_cell"] :[self tableView]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.reachability = [Reachability reachabilityForInternetConnection];
    if (! self.coinStatusObserver) {
        NSLog(@"need to add observer here ");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.coinStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.coinStatusObserver];
    self.coinStatusObserver = nil;
    
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    if (self.coinStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.coinStatusObserver];
}

- (void)getCoinInfo:(NSDictionary *)coin
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *lcc = [manager localCurrencyCode];
    NSString *coinCode = [_coin valueForKey:@"symbol"];
}

- (void)setCoin:(NSDictionary *)coin {
    
    NSMutableArray *histMIN = [NSMutableArray array], *histHR = [NSMutableArray array], *histDAY = [NSMutableArray array];
    
    _coin = coin;
    NSLog(@"get coin info here");

    self.histMIN = histMIN;
    self.histHR = histHR;
    self.histDAY = histDAY;
}

- (void)setBackgroundForCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)path {
//    [cell viewWithTag:100].hidden = (path.row > 0);
//    [cell viewWithTag:101].hidden = (path.row + 1 < [self tableView:self.tableView numberOfRowsInSection:path.section]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    switch (section) {
        case 0: return 3;
        case 1: return 1;
        case 2: return 5;
        case 3: return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UITableViewCell *cell;
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    UILabel *coidId, *coindName, *coinSymbol, *coinRank, *coinPrice_usd, *coinPrice_btc, *coin24h_volume_usd, *coinMarket_cap_usd, *coinAvailable_supply, *coinTotal_supply, *coinPercent_change_1h, *coinPercent_change_24h, *coinPercent_change_7d, *coinLast_updated, *localCurrencyLabel, *coinPercent_change;
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"IdCell" forIndexPath:indexPath];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    coindName = (id)[cell viewWithTag:1];
                    coinSymbol = (id)[cell viewWithTag:2];
                    [self setBackgroundForCell:cell indexPath:indexPath];
                    coindName.text = [_coin valueForKey:@"name"];
                    coinSymbol.text = [[@" - (" stringByAppendingString:[_coin valueForKey:@"symbol"]] stringByAppendingString:@")" ];
                    break;
                }
                case 1: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentPriceCell" forIndexPath:indexPath];

                    manager.format.maximumFractionDigits = 8;
                    NSString *price_btc = [_coin valueForKey:@"price_btc"];
                    CGFloat btcAmount = [price_btc floatValue];
                    NSString *btcAmountStr = [NSString stringWithFormat:@"%.8f BTC",btcAmount];
                    
                    coinPrice_btc = (id)[cell viewWithTag:4];
                    coinPrice_btc.text = [NSString stringWithFormat:@"%@",btcAmountStr];
                    
                    localCurrencyLabel = (id)[cell viewWithTag:3];
                    localCurrencyLabel.text = [NSString stringWithFormat:@" (%@)",[manager localCurrencyStringForAmount: btcAmount*100000000]];
                    break;
                }
                case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentRangePriceChangeCell" forIndexPath:indexPath];
                    _currentRangeChangePercentageCell = cell;
                    coinPercent_change = (id)[cell viewWithTag:99];
                    coinPercent_change.text = [NSString stringWithFormat:@"%@ %@", _histoRangeString, @""];
                    _currentRangeChangePercentage = coinPercent_change;
                }
                default: {
                    break;
                }
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        }case 2: {
            // STATS
            switch (indexPath.row) {
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"ValueChangeCell" forIndexPath:indexPath];
                    coinPercent_change_1h = (id)[cell viewWithTag:5];
                    coinPercent_change_24h = (id)[cell viewWithTag:6];
                    coinPercent_change_7d = (id)[cell viewWithTag:7];
                    
                    NSString *cpc1h =[_coin valueForKey:@"percent_change_1h"];
                    if(cpc1h==[NSNull null]) {
                        cpc1h=@"0";
                    }
                    coinPercent_change_1h.text = [cpc1h stringByAppendingString: @"%"];
                    if([cpc1h doubleValue]<0.0){
                        coinPercent_change_1h.textColor = [UIColor redColor];
                    }else{
                        coinPercent_change_1h.textColor = [UIColor greenColor];
                    }
                    
                    NSString *cpc24h =[_coin valueForKey:@"percent_change_24h"];
                    if(cpc24h==[NSNull null]) {
                        cpc24h=@"0";
                    }
                    coinPercent_change_24h.text = [cpc24h stringByAppendingString: @"%"];
                    if([cpc24h doubleValue]<0.0){
                        coinPercent_change_24h.textColor = [UIColor redColor];
                    }else{
                        coinPercent_change_24h.textColor = [UIColor greenColor];
                    }
                    
                    NSString *cpc7d =[_coin valueForKey:@"percent_change_7d"];
                    if(cpc7d==[NSNull null]) {
                        cpc7d=@"0";
                    }
                    coinPercent_change_7d.text = [cpc7d stringByAppendingString: @"%"];
                    if([cpc7d doubleValue]<0.0){
                        coinPercent_change_7d.textColor = [UIColor redColor];
                    }else{
                        coinPercent_change_7d.textColor = [UIColor greenColor];
                    }
                    [self setBackgroundForCell:cell indexPath:indexPath];
                    break;
                }
                case 1:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"StatsMarketCap" forIndexPath:indexPath];
                    NSString *market_cap_usd =[_coin valueForKey:@"market_cap_usd"];
                    coinMarket_cap_usd = (id)[cell viewWithTag:11];
                    
                    NSNumberFormatter *formatter = [NSNumberFormatter new];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
                    
                    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[market_cap_usd doubleValue]]];
                    
                    
                    coinMarket_cap_usd.text = [NSString stringWithFormat:@"$ %@",formatted];
                    break;
                }
                case 2:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"StatsVol24Hr" forIndexPath:indexPath];
                    NSString *volume_usd_24 =[_coin valueForKey:@"24h_volume_usd"];
                    coin24h_volume_usd = (id)[cell viewWithTag:12];
                    
                    NSNumberFormatter *formatter = [NSNumberFormatter new];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
                    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[volume_usd_24 doubleValue]]];

                    coin24h_volume_usd.text = [NSString stringWithFormat:@"$ %@",formatted];
                    break;
                }
                case 3:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"StatsAvailableSupply" forIndexPath:indexPath];
                    NSString *available_supply =[_coin valueForKey:@"available_supply"];
                    coinAvailable_supply = (id)[cell viewWithTag:13];
                    
                    NSNumberFormatter *formatter = [NSNumberFormatter new];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
                    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[available_supply doubleValue]]];
                    
                    NSString *cc = [_coin valueForKey:@"symbol"];
                    
                    coinAvailable_supply.text = [NSString stringWithFormat:@"%@ %@",cc, formatted];
                    break;
                }
                case 4:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"StatsPercentChange24Hr" forIndexPath:indexPath];
                    NSString *max_supply =[_coin valueForKey:@"max_supply"];
                    coinTotal_supply = (id)[cell viewWithTag:14];
                    
                    NSNumberFormatter *formatter = [NSNumberFormatter new];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
                    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:[max_supply doubleValue]]];
                    
                    NSString *cc = [_coin valueForKey:@"symbol"];
                    
                    coinTotal_supply.text = [NSString stringWithFormat:@"%@ %@",cc, formatted];
                    break;
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self setBackgroundForCell:cell indexPath:indexPath];
            break;
        }
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"line_chart_cell"];
            cell = [self initializeWithChartType:ChartTypeLine :tableView];
            [self setBackgroundForCell:cell indexPath:indexPath];
            break;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return nil;
        case 1: return nil;
        case 2: return @"STATS";
    }
    return nil;
}

#pragma mark: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: return 44.0;
        case 1: return 250.0;
        case 2: return 44.0;
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    if (sectionTitle.length == 0) return 24.0;
    
    CGRect textRect = [sectionTitle boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30.0, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17]} context:nil];
    
    return textRect.size.height + 12.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width,
                                                                  [self tableView:tableView heightForHeaderInSection:section])];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, headerview.frame.size.width - 30.0,
                                                                    headerview.frame.size.height - 12.0)];
    
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    titleLabel.numberOfLines = 0;
    headerview.backgroundColor = [UIColor clearColor];
    [headerview addSubview:titleLabel];
    
    return headerview;
}

@end
