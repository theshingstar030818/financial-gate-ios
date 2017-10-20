//
//  BRTEST.m
//  BreadWallet
//
//  Created by Syed Askari on 13/04/2017.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

// Updated by Farrukh Askari <farrukh.askari01@gmail.com> on 3:22 PM 17/4/17.

#import "BRTEST.h"

@interface BRTEST ()
@property (weak, nonatomic) IBOutlet UIButton *debitButton;
@property (weak, nonatomic) IBOutlet UIButton *investButton;
@property (weak, nonatomic) IBOutlet UIButton *tradeButton;

@end

@implementation BRTEST

UIViewController *destinationController = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.debitButton.layer.cornerRadius = 10;
    self.debitButton.layer.borderWidth = 2;
    self.debitButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.investButton.layer.cornerRadius = 10;
    self.investButton.layer.borderWidth = 2;
    self.investButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.tradeButton.layer.cornerRadius = 10;
    self.tradeButton.layer.borderWidth = 2;
    self.tradeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear{
    self.debitButton.layer.cornerRadius = 10;
    self.debitButton.layer.borderWidth = 2;
    self.debitButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.investButton.layer.cornerRadius = 10;
    self.investButton.layer.borderWidth = 2;
    self.investButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.tradeButton.layer.cornerRadius = 10;
    self.tradeButton.layer.borderWidth = 2;
    self.tradeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (IBAction)debitCardCharge:(UIButton *)sender {
    destinationController = [self.storyboard instantiateViewControllerWithIdentifier:@"DebitCardBalance"];
    [self.navigationController pushViewController:destinationController animated:YES];
}

- (IBAction)invest:(UIButton *)sender {
    destinationController = [self.storyboard instantiateViewControllerWithIdentifier:@"BTC"];
    [self.navigationController pushViewController:destinationController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
