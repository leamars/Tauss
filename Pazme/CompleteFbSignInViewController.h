//
//  CompleteFbSignInViewController.h
//  Pazme
//
//  Created by Lea Marolt on 7/10/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompleteFbSignInViewController : UIViewController

// Properties
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *notIntendedUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

// Actions
- (IBAction)notIntendedUser:(id)sender;
- (IBAction)forward:(id)sender;

@end
