//
//  SignUpViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import <FBShimmering.h>
#import <FBShimmeringView.h>
#import "HTAutoCompleteManager.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController {
    NSString *username;
    NSString *password;
    NSString *email;
    BOOL optional;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    optional = true;
    
    self.emailField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.emailField.autocompleteType = HTAutocompleteTypeEmail;
}

- (void) viewWillAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        //DO SOMETHING IF WE GET TO THIS SCREEN BY MISTAKE AND THE USER IS ALREADY LOGGED IN
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Text Field Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get rid of keyboard when you touch anywhere on the screen
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self saveData];
    
    [textField resignFirstResponder];
    [self signUp:self.signUpButton];
    
    return NO;
}

- (IBAction)signUp:(id)sender {
    
    [self saveData];
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Looks like you didn't enter information for all the fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        
        // IF WE NEED OTHER THINGS FOR THE OBJECT LIKE AGE/GENDER OR W/E
        // newUser[@"name"] = name;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry." message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
            }
            else {
                if (optional) {
                    PFUser *currentUser = [PFUser currentUser];
                    NSLog(@"USER: %@", currentUser);
                    [self performSegueWithIdentifier:@"toOpt" sender:self];
                }
                else {
                    [self performSegueWithIdentifier:@"signUpToInterests" sender:self];
                }
            }
            
        }];
    }
}

- (void) saveData {
    username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
