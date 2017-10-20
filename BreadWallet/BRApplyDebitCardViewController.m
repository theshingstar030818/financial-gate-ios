//
//  BRApplyDebitCardViewController.m
//  BreadWallet
//
//  Created by Mac on 8/24/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRApplyDebitCardViewController.h"
#import "BRBubbleView.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRKey.h"
#import "BRTransaction.h"
#import "NSString+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "BREventManager.h"
#import "FinancialGate-Swift.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Utils.h"
#import "BRAppGroupConstants.h"
#import "BRWalletManager.h"
#import "BRPdfPageView.h"
#import "RP_UIView_2_PDF.h"

@interface BRApplyDebitCardViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *birthField;

@property (weak, nonatomic) IBOutlet UIImageView *imgIdCard;
@property (weak, nonatomic) IBOutlet UIButton *btnDelForIdCard;
@property (weak, nonatomic) IBOutlet UIImageView *imgAddrCard;
@property (weak, nonatomic) IBOutlet UIButton *btnDelForAddrCard;

@property (strong, nonatomic) NSData *pdfData;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (assign, nonatomic) BOOL isIdCard;

@end

@implementation BRApplyDebitCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imgIdCard.hidden = YES;
    self.btnDelForIdCard.hidden = YES;
    self.imgAddrCard.hidden = YES;
    self.btnDelForAddrCard.hidden = YES;
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.birthField setInputView:self.datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(showSelectedDate)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    [self.birthField setInputAccessoryView:toolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSelectedDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    self.birthField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:self.datePicker.date]];
    [self.birthField resignFirstResponder];
}

- (void)selectPhotosFromCamera {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (NSArray *)generateExamplePages {
    
    NSMutableArray *collection = [@[] mutableCopy];
    
    BRPdfPageView *pdfPageView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BRPdfPageView class]) owner:self options:nil].lastObject;
    
    pdfPageView.txtTitle.text = NSLocalizedString(@"Apply For Debit Card :", nil);
    pdfPageView.txtPersonalInfo.text = NSLocalizedString(@"Personal Info :", nil);
    pdfPageView.txtName.text = NSLocalizedString(@"Name :", nil);
    pdfPageView.lblName.text = [NSString stringWithFormat:@"%@ %@", self.firstNameField.text, self.lastNameField.text];
    pdfPageView.txtBirth.text = NSLocalizedString(@"Date of Birth :", nil);
    pdfPageView.lblBirth.text = self.birthField.text;
    
    pdfPageView.txtIDtitle.text = NSLocalizedString(@"National Identity :", nil);
    pdfPageView.imvIDcard.image = self.imgIdCard.image;
    
    pdfPageView.txtContactInfo.text = NSLocalizedString(@"Contact Info :", nil);
    pdfPageView.txtAddress.text = NSLocalizedString(@"Address :", nil);
    pdfPageView.lblAddress.text = [NSString stringWithFormat:@"%@, %@ %@", self.addressField.text, self.zipCodeField.text, self.cityField.text];
    pdfPageView.txtEmail.text = NSLocalizedString(@"Email :", nil);
    pdfPageView.lblEmail.text = self.emailField.text;
    pdfPageView.txtPhone.text = NSLocalizedString(@"Phone No :", nil);
    pdfPageView.lblPhone.text = self.phoneNumberField.text;
    
    pdfPageView.txtCertificate.text = NSLocalizedString(@"Address Certificate :", nil);
    pdfPageView.imvCertificate.image = self.imgAddrCard.image;
    
    [collection addObject:pdfPageView];
    
    return [collection copy];
}

- (BOOL)verificationForApply {
    NSString *msg = nil;
    
    if (self.firstNameField.text == nil || [self.firstNameField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your first name", nil);
    } else if (self.lastNameField.text == nil || [self.lastNameField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your last name", nil);
    } else if (self.addressField.text == nil || [self.addressField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your address", nil);
    } else if (self.cityField.text == nil || [self.cityField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter the name of city you live", nil);
    } else if (self.zipCodeField.text == nil || [self.zipCodeField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your zip code", nil);
    } else if (self.phoneNumberField.text == nil || [self.phoneNumberField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your phone number", nil);
    } else if (self.emailField.text == nil || [self.emailField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your email", nil);
    } else if (self.birthField.text == nil || [self.birthField.text isEqualToString:@""]) {
        msg = NSLocalizedString(@"please enter your birthday", nil);
    } else {
        return true;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert", nil)
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                      }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
    
    return false;
}

// Mark: - IBAction

- (IBAction)deleteIDcard:(id)sender {
    self.imgIdCard.image = nil;
    self.imgIdCard.hidden = YES;
    self.btnDelForIdCard.hidden = YES;
}

- (IBAction)deleteAddrCert:(id)sender {
    self.imgAddrCard.image = nil;
    self.imgAddrCard.hidden = YES;
    self.btnDelForAddrCard.hidden = YES;
}

- (IBAction)uploadIdCard:(id)sender {
    self.isIdCard = true;
    [self selectPhotosFromCamera];
}

- (IBAction)uploadAddressID:(id)sender {
    self.isIdCard = false;
    [self selectPhotosFromCamera];
}

- (IBAction)sendMailForDebitCard:(id)sender {
   if ([self verificationForApply]) {
        [BREventManager saveEvent:@"debit_card:send"];
        
        NSArray *pdf = [self generateExamplePages];
        NSString *pdfFilepath = [RP_UIView_2_PDF generatePDFWithPages:pdf];
        self.pdfData = [NSData dataWithContentsOfFile:pdfFilepath];
        
        UIActionSheet *actionSheet = [UIActionSheet new];
        actionSheet.delegate = self;
    
        if ([MFMailComposeViewController canSendMail]) {
            [actionSheet addButtonWithTitle:NSLocalizedString(@"send request for debit card as email", nil)];
        }
    
#if ! TARGET_IPHONE_SIMULATOR
        if ([MFMessageComposeViewController canSendText]) {
            [actionSheet addButtonWithTitle: NSLocalizedString(@"send request for debit card as message", nil)];
        }
#endif
    
        [actionSheet addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark: - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    //TODO: allow user to create a payment protocol request object, and use merge avoidance techniques:
    // https://medium.com/@octskyward/merge-avoidance-7f95a386692f
    
    if ([title isEqual:NSLocalizedString(@"send request for debit card as email", nil)]) {
        //TODO: implement BIP71 payment protocol mime attachement
        // https://github.com/bitcoin/bips/blob/master/bip-0071.mediawiki
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *composeController = [MFMailComposeViewController new];
            
            composeController.subject = NSLocalizedString(@"Bitcoin address", nil);
            [composeController addAttachmentData:self.pdfData mimeType:@"application/pdf" fileName:@"temp.pdf"];
            composeController.mailComposeDelegate = self;
            [self.navigationController presentViewController:composeController animated:YES completion:nil];
            composeController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
            
            [BREventManager saveEvent:@"debit_card:send_email"];
        }
        else {
            [BREventManager saveEvent:@"debit_card:email_not_configured"];
            
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
    else if ([title isEqual:NSLocalizedString(@"send request for debit card as message", nil)]) {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *composeController = [MFMessageComposeViewController new];
            
            if ([MFMessageComposeViewController canSendSubject]) {
                composeController.subject = NSLocalizedString(@"Bitcoin address", nil);
            }
            
            if ([MFMessageComposeViewController canSendAttachments]) {
                [composeController addAttachmentData:self.pdfData typeIdentifier:(NSString *)kUTTypePDF filename:@"temp.pdf"];
            }
            
            composeController.messageComposeDelegate = self;
            [self.navigationController presentViewController:composeController animated:YES completion:nil];
            composeController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper-default"]];
            [BREventManager saveEvent:@"debit_card:send_message"];
        }
        else {
            [BREventManager saveEvent:@"debit_card:message_not_configured"];
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@""
                                         message:NSLocalizedString(@"sms not currently available", nil)
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
}

#pragma mark: - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark: - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark: - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (self.isIdCard) {
        self.imgIdCard.hidden = NO;
        self.imgIdCard.image = info[UIImagePickerControllerOriginalImage];
        self.btnDelForIdCard.hidden = NO;
    } else {
        self.imgAddrCard.hidden = NO;
        self.imgAddrCard.image = info[UIImagePickerControllerOriginalImage];
        self.btnDelForAddrCard.hidden = NO;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
