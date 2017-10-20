//
//  BRSupportViewController.h
//  FinancialGate
//
//  Created by Mac on 9/25/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface BRSupportViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextView *inquiryTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end
