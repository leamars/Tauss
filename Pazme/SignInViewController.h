//
//  SignInViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController <UITextFieldDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

// Actions
- (IBAction)signIn:(id)sender;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end
