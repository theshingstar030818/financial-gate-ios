//
//  BRSendBalanceViewController.m
//  BreadWallet
//
//  Created by Mac on 8/24/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRSendBalanceViewController.h"
#import "BRScanViewController.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "BREventManager.h"
#import "NSString+Bitcoin.h"

#define SCAN_TIP      NSLocalizedString(@"Scan someone else's QR code to get their bitcoin address. "\
"You can send a payment to anyone with an address.", nil)

@interface BRSendBalanceViewController ()
@property (weak, nonatomic) IBOutlet UITextField *editRecipent;
@property (weak, nonatomic) IBOutlet UITextView *txtMemo;
@property (weak, nonatomic) IBOutlet UITextField *editBTC;
@property (weak, nonatomic) IBOutlet UITextField *editUSD;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *btnBTC;
@property (weak, nonatomic) IBOutlet UIButton *btnUSD;
@property (nonatomic, strong) IBOutlet UIView *logo;
@property (nonatomic, strong) BRScanViewController *scanController;
@property (nonatomic, assign) uint64_t amount;
@property (nonatomic, strong) NSCharacterSet *charset;
@property (nonatomic, strong) id balanceObserver, backgroundObserver;
@end

@implementation BRSendBalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sendButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSMutableCharacterSet *charset = [NSMutableCharacterSet decimalDigitCharacterSet];
    
    [charset addCharactersInString:manager.format.currencyDecimalSeparator];
    self.charset = charset;
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *strPaste = pasteboard.string;
    if (strPaste != nil && ![strPaste isEqualToString:@""]) {
        if ([self checkBitcoinAddress:strPaste]) {
            self.editRecipent.text = strPaste;
        } else {
            self.editRecipent.text = @"";
        }
    }
    
    self.editBTC.delegate = self;
    self.editUSD.delegate = self;
    
    [self.btnBTC setTitle:@"BTC0.00000000" forState:UIControlStateNormal];
    [self.btnBTC setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.btnUSD setTitle:[manager localCurrencyStringForAmount:(uint64_t)0] forState:UIControlStateNormal];
    [self.btnUSD setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    self.balanceObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil queue:nil
                                                  usingBlock:^(NSNotification *note) {
        if ([BRPeerManager sharedInstance].syncProgress < 1.0) return; // wait for sync before updating balance
    }];
    
    self.backgroundObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
        self.navigationItem.titleView = self.logo;
    }];
    
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIStatusBarStyleLightContent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"X" style:UIBarButtonItemStyleDone target:self action:@selector(cancelNumberPad)]];
    [numberToolbar sizeToFit];
    [numberToolbar setBarTintColor:[UIColor whiteColor]];
    _editBTC.inputAccessoryView = numberToolbar;
    _editUSD.inputAccessoryView = numberToolbar;
    _txtMemo.inputAccessoryView = numberToolbar;
    _editRecipent.inputAccessoryView = numberToolbar;
}

-(void)cancelNumberPad
{
    [_editBTC resignFirstResponder];
    [_editUSD resignFirstResponder];
    [_txtMemo resignFirstResponder];
    [_editRecipent resignFirstResponder];
}

- (void)dealloc {
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (! self.scanController) {
        self.scanController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)resetQRGuide {
    self.scanController.message.text = nil;
    self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide"];
}

- (NSString *)updateBalance:(uint64_t)amount {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    manager.format.maximumFractionDigits = 8;
    NSString *btcAmount = [[manager stringForAmount: amount] stringByReplacingOccurrencesOfString:@"ƀ" withString:@""];

    NSString *btcAmountStr = [NSString stringWithFormat:@"BTC%@", btcAmount];
    
    return btcAmountStr;
}

- (BOOL)checkBitcoinAddress:(NSString *)addr {
    BRPaymentRequest *request = [BRPaymentRequest requestWithString:addr];
    if ((request.isValid && [request.scheme isEqual:@"bitcoin"]) || [addr isValidBitcoinPrivateKey] ||
        [addr isValidBitcoinBIP38Key]) {
        return true;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert", nil)
                                                                       message:NSLocalizedString(@"not a bitcoin address", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return false;
}


// Mark: - IBAction

- (IBAction)done:(id)sender {
    [BREventManager saveEvent:@"send_balance:dismiss"];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)continueToSend:(id)sender {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    self.amount = [manager amountForLocalCurrencyString:self.editUSD.text];
    
    if (self.amount == 0){
        [BREventManager saveEvent:@"amount:pay_zero"];
        return;
    }
    
    BRPaymentRequest *request = [BRPaymentRequest requestWithString:self.editRecipent.text];
    request.amount = self.amount;
    request.message = self.txtMemo.text;
    if (request.r != nil) {
        [BRPaymentRequest fetch:request.r timeout:5.0 completion:^(BRPaymentProtocolRequest *req, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) request.r = nil;
                
                if (error) {
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:NSLocalizedString(@"couldn't make payment", nil)
                                                 message:error.localizedDescription
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"ok", nil)
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                }];
                    
                    [alert addAction:yesButton];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    [BREventManager saveEvent:@"send:successful_qr_payment_protocol_fetch"];
                    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                        [self.delegate sendBalanceViewController:self request:(BRPaymentProtocolRequest *)req  amount:(uint64_t)self.amount];
                    }];
                }
            });
        }];
    } else {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self.delegate sendBalanceViewController:self confirmRequest:(BRPaymentRequest *)request  amount:(uint64_t)self.amount];
        }];
    }
}

- (IBAction)scanQRcode:(id)sender {
    [BREventManager saveEvent:@"send_balance:scan_qr"];
    self.scanController.delegate = self;
    self.scanController.transitioningDelegate = self;
    [self.navigationController presentViewController:self.scanController animated:YES completion:nil];
}

#pragma mark: - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataMachineReadableCodeObject *codeObject in metadataObjects) {
        if (! [codeObject.type isEqual:AVMetadataObjectTypeQRCode]) continue;
        
        [BREventManager saveEvent:@"send_balance:scanned_qr"];
        
        NSString *addr = [codeObject.stringValue stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BRPaymentRequest *request = [BRPaymentRequest requestWithString:addr];
        if ((request.isValid && [request.scheme isEqual:@"bitcoin"]) || [addr isValidBitcoinPrivateKey] ||
                   [addr isValidBitcoinBIP38Key]) {
            self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-green"];
            [self.scanController stop];
            [BREventManager saveEvent:@"send_balance:valid_qr_scan"];
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                NSString *addrWithoutSpaces = [addr stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
                [self.editRecipent setText:addrWithoutSpaces];
                [self resetQRGuide];
            }];
        } else {
            self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-red"];
            self.scanController.message.text = NSLocalizedString(@"not a bitcoin QR code", nil);
            [self performSelector:@selector(resetQRGuide) withObject:nil afterDelay:0.35];
            [BREventManager saveEvent:@"send_balance:unsuccessful_bip73"];
        }
        
        break;
    }
}

#pragma mark UIActions

- (IBAction)onBTC:(id)sender {
    [self.editBTC becomeFirstResponder];
}

- (IBAction)onUSD:(id)sender {
    [self.editUSD becomeFirstResponder];
}

#pragma mark: - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL localFlag = NO;
    if (textField == self.editUSD) {
        localFlag = YES;
    }
    
    if (textField == self.editBTC || textField == self.editUSD) {
        
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        NSNumberFormatter *numberFormatter = (localFlag) ? manager.localFormat : manager.format;
        
        NSString *textVal = textField.text;
        NSUInteger decimalLoc = [textVal rangeOfString:numberFormatter.currencyDecimalSeparator].location;
        NSUInteger minimumFractionDigits = numberFormatter.minimumFractionDigits;
        NSString *zeroStr = nil;
        NSDecimalNumber *num;
        
        if (! textVal) textVal = @"";
        numberFormatter.maximumFractionDigits = (localFlag) ? 2 : 8;
        numberFormatter.minimumFractionDigits = 0;
        zeroStr = [numberFormatter stringFromNumber:@0];
        
        // if amount is prefixed with currency symbol, then equivalent to [zeroStr stringByAppendingString:numberFormatter.currencyDecimalSeparator]
        // otherwise, numberFormatter.currencyDecimalSeparator must be inserted exactly after 0
        NSString *(^zeroStrByInsertingCurrencyDecimalSeparator)() = ^NSString * {
            NSRange zeroCharacterRange = [zeroStr rangeOfCharacterFromSet:self.charset];
            return [zeroStr stringByReplacingCharactersInRange:NSMakeRange(NSMaxRange(zeroCharacterRange), 0)
                                                    withString:numberFormatter.currencyDecimalSeparator];
        };
        
        if (string.length == 0) { // delete button
            
            textVal = [textVal stringByReplacingCharactersInRange:range withString:string];
            
            if (range.location <= decimalLoc) { // deleting before the decimal requires reformatting
                textVal = [numberFormatter stringFromNumber:[numberFormatter numberFromString:textVal]];
            }
            
            if (! textVal || [textVal isEqual:zeroStr]) textVal = @""; // check if we are left with a zero amount
        }
        else if ([string isEqual:numberFormatter.currencyDecimalSeparator]) { // decimal point button
            if (decimalLoc == NSNotFound && numberFormatter.maximumFractionDigits > 0) {
                 textVal = (textVal.length == 0) ? zeroStrByInsertingCurrencyDecimalSeparator() : [textVal stringByReplacingCharactersInRange:range withString:string];
            }
        }
        else { // digit button
            // check for too many digits after the decimal point

            if (range.location > decimalLoc && range.location - decimalLoc > numberFormatter.maximumFractionDigits) {
                numberFormatter.minimumFractionDigits = numberFormatter.maximumFractionDigits;
                num = [NSDecimalNumber decimalNumberWithDecimal:[numberFormatter numberFromString:textVal].decimalValue];
                num = [num decimalNumberByMultiplyingByPowerOf10:1];
                num = [num decimalNumberByAdding:[[NSDecimalNumber decimalNumberWithString:string]
                                                  decimalNumberByMultiplyingByPowerOf10:-numberFormatter.maximumFractionDigits]];
                textVal = [numberFormatter stringFromNumber:num];
                if (! [numberFormatter numberFromString:textVal]) textVal = nil;
            }
            else if (textVal.length == 0 && [string isEqual:@"0"]) { // if first digit is zero, append decimal point
                textVal = zeroStrByInsertingCurrencyDecimalSeparator();
            }
            else if (range.location > decimalLoc && [string isEqual:@"0"]) { // handle multiple zeros after decimal point
                textVal = [textVal stringByReplacingCharactersInRange:range withString:string];
            }
            else {
                textVal = [numberFormatter stringFromNumber:[numberFormatter numberFromString:[textVal
                                                            stringByReplacingCharactersInRange:range withString:string]]];
            }
        }
        
        if (textVal)    textField.text = textVal;
        numberFormatter.minimumFractionDigits = minimumFractionDigits;
        
        if (textVal.length == 0) {
            textField.hidden = NO;
            textField.placeholder = (localFlag) ? [manager localCurrencyStringForAmount:(uint64_t)0] : @"BTC 0.00000000";
        } else {
            textField.hidden = YES;
            textField.placeholder = @"";
        }
        
        UITextField *otherEditField = (localFlag) ? self.editBTC : self.editUSD;

        uint64_t amount = (localFlag) ? [manager amountForLocalCurrencyString:textVal] : [manager amountForString:textVal];
        NSString *otherAmountStr = (localFlag) ? [self updateBalance:amount] : [manager localCurrencyStringForAmount:amount];
        
        if (amount == 0) {
            otherAmountStr = @"";
            otherEditField.text = @"";
        } else {
            if (localFlag) {
                otherEditField.text = [otherAmountStr stringByReplacingOccurrencesOfString:@"BTC" withString:@""];
            } else {
                otherEditField.text = otherAmountStr;
            }
        }
        
        otherEditField.textColor = (amount > 0) ? [UIColor grayColor] : [UIColor colorWithWhite:0.75 alpha:1.0];
        
        if (otherEditField.text.length == 0) {
            otherEditField.hidden = NO;
            otherEditField.placeholder = (localFlag) ? @"BTC 0.00000000" : [manager localCurrencyStringForAmount:(uint64_t)0];
        } else {
            otherEditField.hidden = YES;
            otherEditField.placeholder = @"";
        }
        
        if (localFlag) {
            [self.btnUSD setTitle:textVal forState:UIControlStateNormal];
            [self.btnUSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.btnBTC setTitle:otherAmountStr forState:UIControlStateNormal];
            [self.btnBTC setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {
            if ([textVal containsString:@"ƀ"]) {
                [self.btnBTC setTitle:[textVal stringByReplacingOccurrencesOfString:@"ƀ" withString:@"BTC"] forState:UIControlStateNormal];
            } else {
                if (textVal.length != 0) {
                    [self.btnBTC setTitle:[NSString stringWithFormat:@"BTC%@", textVal] forState:UIControlStateNormal];
                } else {
                    [self.btnBTC setTitle:textVal forState:UIControlStateNormal];
                }
            }
            [self.btnBTC setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [self.btnUSD setTitle:otherAmountStr forState:UIControlStateNormal];
            [self.btnUSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    return NO;
}


@end

