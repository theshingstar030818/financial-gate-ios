//
//  BRPdfPageView.h
//  BreadWallet
//
//  Created by Mac on 8/25/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRPdfPageView : UIView

@property (weak, nonatomic) IBOutlet UILabel *txtTitle;

@property (weak, nonatomic) IBOutlet UILabel *txtPersonalInfo;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *txtBirth;
@property (weak, nonatomic) IBOutlet UILabel *lblBirth;
@property (weak, nonatomic) IBOutlet UILabel *txtIDtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imvIDcard;

@property (weak, nonatomic) IBOutlet UILabel *txtContactInfo;
@property (weak, nonatomic) IBOutlet UILabel *txtAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *txtEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *txtPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *txtCertificate;
@property (weak, nonatomic) IBOutlet UIImageView *imvCertificate;

@end
