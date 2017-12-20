
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

#define COIN_CELL_HEIGHT 75
#define header_height 10

#define CHART_LINE 0
#define CHART_HORIZONTAL_STACK 1
#define CHART_PIE 2
#define CHART_BAR 3
#define CHART_CIRCULAR 4

@interface BRCoinDetailViewController ()<MultiLineGraphViewDataSource, MultiLineGraphViewDelegate, PieChartDataSource, PieChartDelegate, HorizontalStackBarChartDataSource, HorizontalStackBarChartDelegate, BarChartDataSource, BarChartDelegate, CircularChartDataSource, CircularChartDelegate>

@property (nonatomic, strong) NSArray *histMIN, *histHR, *histDAY;
@property (nonatomic, strong) id coinStatusObserver;

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

#pragma Mark CreateLineGraph
- (UITableViewCell *)createLineGraph:(UITableView*)tableView{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"line_chart_cell"];
    UIView *graphView = (id)[cell viewWithTag:8];
    MultiLineGraphView *graph = [[MultiLineGraphView alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(cell), 250.0 - header_height)];
    [graph setDelegate:self];
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
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (CGFloat)widthForTheLineWithLineNumber:(NSInteger)lineNumber{
    return 1;
}

- (NSString *)nameForTheLineWithLineNumber:(NSInteger)lineNumber{
    return [NSString stringWithFormat:@"data %ld",(long)lineNumber];
}

- (BOOL)shouldFillGraphWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return false;
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
            return true;
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
            for (int i = 20; i < 30; i++) {
                [array addObject:[NSNumber numberWithLong:random() % 100]];
            }
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
            for (int i = 21; i <= 30; i++) {
                [array addObject:[NSString stringWithFormat:@"%d Jun", i]];
            }
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
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.layer setCornerRadius:4.0F];
    [view.layer setBorderWidth:1.0F];
    [view.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowRadius:2.0F];
    [view.layer setShadowOpacity:0.3F];
    
    CGFloat y = 0;
    CGFloat width = 0;
    for (int i = 0; i < 3 ; i++) {
        UILabel *label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[NSString stringWithFormat:@"Line Data:y = %@ x = %@", yValue, xValue]];
        [label setFrame:CGRectMake(0, y, 200, 30)];
        [view addSubview:label];
        
        width = WIDTH(label);
        y = BOTTOM(label);
    }
    
    [view setFrame:CGRectMake(0, 0, width, y)];
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
        case 0: return 2;
        case 1: return 1;
        case 2: return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    UILabel *coidId, *coindName, *coinSymbol, *coinRank, *coinPrice_usd, *coinPrice_btc, *coin24h_volume_usd, *coinMarket_cap_usd, *coinAvailable_supply, *coinTotal_supply, *coinPercent_change_1h, *coinPercent_change_24h, *coinPercent_change_7d, *coinLast_updated, *localCurrencyLabel;
    
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
                    cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];

                    manager.format.maximumFractionDigits = 8;
                    NSString *price_btc = [_coin valueForKey:@"price_btc"];
                    CGFloat btcAmount = [price_btc floatValue];
                    NSString *btcAmountStr = [NSString stringWithFormat:@"%.8f BTC",btcAmount];
                    
                    coinPrice_btc = (id)[cell viewWithTag:4];
                    coinPrice_btc.text = [NSString stringWithFormat:@"%@",btcAmountStr];
                    
                    localCurrencyLabel = (id)[cell viewWithTag:3];
                    localCurrencyLabel.text = [NSString stringWithFormat:@" (%@)",[manager localCurrencyStringForAmount: btcAmount*100000000]];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
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
        case 2: {
            cell = [self initializeWithChartType:ChartTypeLine :tableView];
//            [cell setBackgroundColor:[UIColor whiteColor]];
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
        case 2: return nil;
    }
    return nil;
}

#pragma mark: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: return 44.0;
        case 1: return 60.0;
        case 2: return 250.0;
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    if (sectionTitle.length == 0) return 22.0;
    
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
