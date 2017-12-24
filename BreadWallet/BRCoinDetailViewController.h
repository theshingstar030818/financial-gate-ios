//
//  BRCoinDetailViewController.m
//  FinancialGate
//
//  Created by Tanzeel Rehman on 2017-12-19.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ChartTypeLine = 0,
    ChartTypeHorizontalStack,
    ChartTypePie,
    ChartTypeBar,
    ChartTypeCircular
}ChartType;

typedef enum{
    hour,
    today,
    hours24,
    oneWeek,
    oneMonth,
    oneYear,
}HistoRange;

@interface BRCoinDetailViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *coin;
@property (nonatomic, strong) NSDictionary *coinHistoMIN;
@property (nonatomic, strong) NSDictionary *coinHistoHR;
@property (nonatomic, strong) NSDictionary *coinHistoDAY;
@property (nonatomic) ChartType chartType;
@property (nonatomic) HistoRange *histoRange;

- (IBAction)rangeChangeButton:(id)sender;
- (instancetype)initWithChartType:(ChartType) type :(UITableView *)tableView;

@end



