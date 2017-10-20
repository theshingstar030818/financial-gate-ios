//
//  RegisterViewController.swift
//  BreadWallet
//
//  Created by Syed Askari on 7/18/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: Any) {
        NSLog(@"Starting new Wallet WOWOWO");
        [BREventManager saveEvent:@"welcome:new_wallet"];
        
        UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
        
            self.generateButton = (id)[c.view viewWithTag:1];
            [self.generateButton addTarget:self action:@selector(generate:) forControlEvents:UIControlEventTouchUpInside];
            self.generateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            self.generateButton.titleLabel.adjustsLetterSpacingToFitWidth = YES;
        #pragma clang diagnostic pop
        
            self.warningLabel = (id)[c.view viewWithTag:2];
            self.showButton = (id)[c.view viewWithTag:3];
            [self.showButton addTarget:self action:@selector(show:) forControlEvents:UIControlEventTouchUpInside];
            self.startLabel = (id)[c.view viewWithTag:4];
            self.recoverLabel = (id)[c.view viewWithTag:5];
        
            NSTextAttachment *noEye = [NSTextAttachment new], *noKey = [NSTextAttachment new];
            NSMutableAttributedString *s = [[NSMutableAttributedString alloc]
                                            initWithAttributedString:self.warningLabel.attributedText];
        
            noEye.image = [UIImage imageNamed:@"no-eye"];
            [s replaceCharactersInRange:[s.string rangeOfString:@"%no-eye%"]
             withAttributedString:[NSAttributedString attributedStringWithAttachment:noEye]];
            noKey.image = [UIImage imageNamed:@"no-key"];
            [s replaceCharactersInRange:[s.string rangeOfString:@"%no-key%"]
             withAttributedString:[NSAttributedString attributedStringWithAttachment:noKey]];
        
            [s replaceCharactersInRange:[s.string rangeOfString:@"WARNING"] withString:NSLocalizedString(@"WARNING", nil)];
            [s replaceCharactersInRange:[s.string rangeOfString:@"\nDO NOT let anyone see your recovery\n"
                                         "phrase or they can spend your bitcoins.\n"]
             withString:NSLocalizedString(@"\nDO NOT let anyone see your recovery\n"
                                          "phrase or they can spend your bitcoins.\n", nil)];
            [s replaceCharactersInRange:[s.string rangeOfString:@"\nNEVER type your recovery phrase into\n"
                                         "password managers or elsewhere.\nOther devices may be infected.\n"]
             withString:NSLocalizedString(@"\nNEVER type your recovery phrase into\npassword managers or elsewhere.\n"
                                          "Other devices may be infected.\n", nil)];
            self.warningLabel.attributedText = s;
            self.generateButton.superview.backgroundColor = [UIColor clearColor];
        
        [self.navigationController pushViewController:c animated:YES];

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
