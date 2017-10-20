//
//  BRSupportViewController.m
//  FinancialGate
//
//  Created by Mac on 9/25/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRSupportViewController.h"
#import "BREventManager.h"

@interface BRSupportViewController ()

@end

@implementation BRSupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    
    [self.sendButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)validationForSupport {
    BOOL isShowAlert = NO;
    NSString *msg;
    
    if (self.nameField.text == nil || [self.nameField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your name", nil);
        isShowAlert = YES;
    } else if (self.emailField.text == nil || [self.emailField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your email", nil);
        isShowAlert = YES;
    } else if (self.inquiryTextView.text == nil || [self.inquiryTextView.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your inquiry", nil);
        isShowAlert = YES;
    } else {
        return YES;
    }
    
    if (isShowAlert) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert", nil)
                                                                       message: msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return NO;
}

#pragma mark - IBAction

- (IBAction)onSend:(id)sender {
    if (![self validationForSupport]) { return; }
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeController = [MFMailComposeViewController new];
        
        composeController.subject = NSLocalizedString(@"Support Request", nil);
        [composeController setToRecipients:@[@"support@financial-gate.info"]];
        NSString *message = [NSString stringWithFormat:@"%@\n%@ %@ (%@ : %@)", self.inquiryTextView.text, NSLocalizedString(@"From", nil), self.nameField.text, NSLocalizedString(@"contact email", nil), self.emailField.text];
        [composeController setMessageBody:message isHTML:NO];
        composeController.mailComposeDelegate = self;
        [self.navigationController presentViewController:composeController animated:YES completion:nil];
        [BREventManager saveEvent:@"support:send_email"];
    }
    else {
        [BREventManager saveEvent:@"support:email_not_configured"];
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:NSLocalizedString(@"email not configured", nil)
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
}


#pragma mark: - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark: - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
