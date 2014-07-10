//
//  CompleteFbSignInViewController.m
//  Pazme
//
//  Created by Lea Marolt on 7/10/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "CompleteFbSignInViewController.h"
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"

@interface CompleteFbSignInViewController () {
    PFUser *currentUser;
}

@end

@implementation CompleteFbSignInViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    currentUser = [PFUser currentUser];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.welcomeLabel.text =  [NSString stringWithFormat:@"Hi %@!", currentUser[@"firstName"]];
    
    self.notIntendedUserLabel.text = [NSString stringWithFormat:@"Not %@?", currentUser[@"firstName"]];
    
    NSString *profilePictureString = [[PFUser currentUser] objectForKey:@"profilePictureURL"];
    //NSString *ppS = [NSString stringWithFormat:@"%@%@", profilePictureString, @"?width=200&height=200"];
    NSURL *profileImageURL = [NSURL URLWithString:profilePictureString];
    [self.profilePictureImageView setImageWithURL:profileImageURL];
    
    self.profilePictureImageView.layer.cornerRadius = 40;
    self.profilePictureImageView.layer.masksToBounds = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)notIntendedUser:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forward:(id)sender {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    currentUser.username = username;
    currentUser.password = password;
    currentUser[@"hasCustomUsername"] = @(YES);
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error"]];
        } else {
            [self performSegueWithIdentifier:@"showInitialFindFriends" sender:self];
        }
    }];
}

#pragma mark - Text Field Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self forward:self.forwardButton];
    
    return NO;
}

#define ACCEPTABLE_CHARECTERS @"abcdefghijklmnopqrstuvwxyz0123456789_."

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == self.usernameField) {
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}

@end
