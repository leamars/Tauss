//
//  SignInViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "SignInViewController.h"
#import <Parse/Parse.h>
#import <FBShimmering.h>
#import <FBShimmeringView.h>
#import "Interests.h"

@interface SignInViewController ()

@end

@implementation SignInViewController {
    NSString *username;
    NSString *password;
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
    
//    self.usernameField.attributedPlaceholder = [self changePlaceholderFont:@"SegoeUISymbol" andColor:[UIColor colorWithRed:213.0/255 green:213.0/255 blue:213.0/255 alpha:213.0/255] andSize:24.0 andString:@"Username"];
//    
//    self.passwordField.attributedPlaceholder = [self changePlaceholderFont:@"SegoeUISymbol" andColor:[UIColor colorWithRed:213.0/255 green:213.0/255 blue:213.0/255 alpha:213.0/255] andSize:24.0 andString:@"Password"];
    
    [self.usernameField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    [self.passwordField setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    
    [self.usernameField.layer setCornerRadius:5.0f];
    [self.passwordField.layer setCornerRadius:5.0f];

    
    // SHIMMER AWAY
    [self shimmerThisView:self.testLabel];

}

- (void) viewWillAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Is there a current user? IT IS: %@", currentUser);
        [self performSegueWithIdentifier:@"signInToInterests" sender:self];
        
    } else {
        NSLog(@"There is no current user.");
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

- (IBAction)signIn:(id)sender {
    
    [self saveData];
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            
                                            [self performSegueWithIdentifier:@"toInterests" sender:self];
                                            
                                            
                                        } else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong. Make sure you're entering the right username and password, and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alert show];
                                        }
                                    }];
}

#pragma mark - UITextFieldDelegate Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get rid of keyboard when you touch anywhere on the screen
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self saveData];
    [textField resignFirstResponder];
    [self signIn:self.loginButton];
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField *)textField up: (BOOL) up
{
    const int movementDistance = 110; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.usernameField.frame = CGRectOffset(self.usernameField.frame, 0, movement);
    self.passwordField.frame = CGRectOffset(self.passwordField.frame, 0, movement);
    self.loginButton.frame = CGRectOffset(self.loginButton.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)listAllFonts {
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
}

#pragma mark - View UI Methods

-(void)shimmerThisView:(UIView *) view {
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:view.frame];
    [self.view addSubview:shimmeringView];
    shimmeringView.contentView = view;
    
    // Start shimmering.
    shimmeringView.shimmering = YES;
}

- (NSAttributedString *)changePlaceholderFont:(NSString *)font andColor:(UIColor *)color andSize:(CGFloat)size andString:(NSString *)string {
    
    NSMutableDictionary *stringAttributes = [NSMutableDictionary dictionaryWithObject:[UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1] forKey:NSForegroundColorAttributeName];
    
    [stringAttributes setObject:[UIFont fontWithName:font size:size] forKey:NSFontAttributeName];
    
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithDictionary:stringAttributes]];
    
    return placeholder;
}

- (void) saveData {
    username = self.usernameField.text;
    password = self.passwordField.text;
}


@end
