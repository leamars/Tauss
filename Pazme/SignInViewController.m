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
#import "SVProgressHUD.h"
#import <POP/POP.h>
#import "UIImage+ImageEffects.h"
#import "UIColor+Tauss.h"
#import "UILabel+BetterLabel.h"

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
    //[self showMainScreen];
    // Do any additional setup after loading the view.
    
//    self.usernameField.attributedPlaceholder = [self changePlaceholderFont:@"SegoeUISymbol" andColor:[UIColor colorWithRed:213.0/255 green:213.0/255 blue:213.0/255 alpha:213.0/255] andSize:24.0 andString:@"Username"];
//    
//    self.passwordField.attributedPlaceholder = [self changePlaceholderFont:@"SegoeUISymbol" andColor:[UIColor colorWithRed:213.0/255 green:213.0/255 blue:213.0/255 alpha:213.0/255] andSize:24.0 andString:@"Password"];
    
//
//    [self.usernameField.layer setCornerRadius:5.0f];
//    [self.passwordField.layer setCornerRadius:5.0f];
        
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    
    [self.taglineLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:14.0]];
    
    // SHIMMER AWAY
    [self shimmerThisView:self.taglineLabel];
    
    //[self slideUpSignInOptions];
    

}

- (void) viewWillAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Is there a current user? IT IS: %@", currentUser);
        [self showMainScreen];
        // Send the user to the main screen if they're already logged in
        
    } else {
        NSLog(@"There is no current user.");
    }

    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:25.0]];
    [self.loginLabel prettyLabel:self.loginLabel];
    [self.facebookLabel prettyLabel:self.facebookLabel];
    [self.signUpLabel prettyLabel:self.signUpLabel];
    
    [self.loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor taussBlue]] forState:UIControlStateHighlighted];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageWithColor:[UIColor taussBlue]] forState:UIControlStateHighlighted];
    [self.signUpButton setBackgroundImage:[UIImage imageWithColor:[UIColor taussBlue]] forState:UIControlStateHighlighted];
    [self.twitterLoginButton setBackgroundImage:[UIImage imageWithColor:[UIColor taussBlue]] forState:UIControlStateHighlighted];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"Lobster1.4" size:70.0]];
    
    //self.testLabel.text = @"LEA IS COOL!";
    //[self.loginButton addSubview:self.testLabel];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
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
                                            
                                            [self showMainScreen];
                                            
                                            
                                        } else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong. Make sure you're entering the right username and password, and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alert show];
                                        }
                                    }];
}

-(IBAction)loginWithFacebook:(id)sender {
        
        [[SVProgressHUD  appearance] setBackgroundColor:[UIColor clearColor]];
        [SVProgressHUD show];
        
        NSArray *permissions = @[ @"email", @"user_friends", @"public_profile"];
        
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            if (!user) {
                if (!error) {
                    NSLog(@"User cancelled the facebook login");
                } else {
                    NSLog(@"An error occured: %@", [error localizedDescription]);
                }
                [SVProgressHUD dismiss];
            } else {
                if (user.isNew) {
                    NSLog(@"NEWWWWW USSSSSEEEERR!!!");
                } else {
                    NSLog(@"User logged back in! ");
                }
                
                //Do some more stuff.
                NSLog(@"fbUser: %@", user);
                
                //Store the user's facebookId.
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (error) {
                        NSLog(@"Something went wrong: %@", [error localizedDescription]);
                        [SVProgressHUD dismiss];
                    } else {
                        NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                        
                        PFUser *currentUser = [PFUser currentUser];
                        currentUser[@"facebookId"] = me.objectID;
                        currentUser[@"firstName"] = me.first_name;
                        currentUser[@"lastName"] = me.last_name;
                        //currentUser[@"birthday"] = nsdate me.birthday;
                        NSLog(@"DATE STRING LOOKS LIKE THIS: %@", me.birthday);
                        currentUser[@"name"] = me.name;
                        // TODO: Figure out why gender doesn't work
                        
                        //If facebook user permitted us to having email.
                        if(me[@"email"]) {
                            //only update the email if there is none.
                            if (!currentUser[@"email"]) {
                                currentUser[@"email"] = me[@"email"];
                            }
                        }
                        
                        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200", me.objectID];
                        
                        //Update the profile picture with a facebook one if there is no profile picture at all. (First time user)
                        if (!currentUser[@"profilePicURL"]) {
                            currentUser[@"profilePicURL"] = profilePictureURL;
                        }
                        
                        
                        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (error) {
                                NSLog(@"I hate errors: %@", [error localizedDescription]);
                                [SVProgressHUD dismiss];
                            } else {
                                NSLog(@"No error, it should've saved");
                                
                                
                                [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    if (error) {
                                        NSLog(@"Really hate errors: %@", [error localizedDescription]);
                                        [SVProgressHUD dismiss];
                                    } else {
                                        
                                        NSLog(@"result: %@", result);
                                        NSArray *data = result[@"data"];
                                        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
                                        for (NSDictionary *friendData in data) {
                                            [facebookIds addObject:friendData[@"id"]];
                                        }
                                        
                                        [[PFUser currentUser] setObject:facebookIds forKey:@"facebookFriends"];
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            
                                            // Whew We're in!
                                            // If the user already has a username and password, we're good. Login normally.
                                            // else send them to the username and password page.
                                            if (currentUser[@"hasCustomUsername"]) {
                                                [PFQuery clearAllCachedResults];
                                                [SVProgressHUD dismiss];
                                                [self showMainScreen];
                                            } else {
                                                [SVProgressHUD dismiss];
                                                [self performSegueWithIdentifier:@"showFbSignIn" sender:self];
                                            }
                                        }];
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        }];
    }

- (void)showMainScreen
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *slideViewController = [mainStoryboard instantiateInitialViewController];
    [self presentViewController:slideViewController animated:NO completion:nil];
}

- (IBAction)loginWithTwitter:(id)sender {
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

#define ACCEPTABLE_CHARECTERS @"abcdefghijklmnopqrstuvwxyz0123456789_.@"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == self.usernameField) {
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
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

#pragma mark - Helper Methods

- (void) saveData {
    username = self.usernameField.text;
    password = self.passwordField.text;
}

- (void) animateTextField: (UITextField *)textField up: (BOOL) up
{
    const int movementDistance = 110; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    const int movementDistanceTwo = 50;
    
    int movement = (up ? -movementDistance : movementDistance);
    int movementTwo = (up ? -movementDistanceTwo : movementDistanceTwo);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.usernameField.frame = CGRectOffset(self.usernameField.frame, 0, movementTwo);
    self.passwordField.frame = CGRectOffset(self.passwordField.frame, 0, movementTwo);
    self.loginButton.frame = CGRectOffset(self.loginButton.frame, 0, movement);
    self.loginLabel.frame = CGRectOffset(self.loginLabel.frame, 0, movement);
    self.separator.frame = CGRectOffset(self.separator.frame, 0, movementTwo);
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

# pragma mark - Animation Methods & Helper Methods

- (void) slideUpSignInOptions {
    
    // Remove all animations
    
    [self.usernameField.layer pop_removeAllAnimations];
    [self.passwordField.layer pop_removeAllAnimations];
    [self.loginButton.layer pop_removeAllAnimations];
    [self.facebookLoginButton.layer pop_removeAllAnimations];
    [self.signUpButton.layer pop_removeAllAnimations];
    
    CALayer *loginLayer = self.loginButton.layer;
    CALayer *facebookLayer = self.facebookLoginButton.layer;
    CALayer *signUpLayer = self.signUpButton.layer;
    
    POPSpringAnimation *right = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    POPSpringAnimation *left = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    
    right.fromValue = @(300);
    right.velocity = @(10.);
    right.completionBlock = ^(POPAnimation *right, BOOL finished) {
        NSLog(@"Login Button");
    };

    left.fromValue = @(-300);
    left.velocity = @(10.);
    left.completionBlock = ^(POPAnimation *left, BOOL finished) {
        NSLog(@"Facebook Button");
    };
    
    //[loginLayer pop_addAnimation:loginButton forKey:@"loginBtnAnim"];
    //[facebookLayer pop_addAnimation:facebookButton forKey:@"facebookBtnAnim"];
    [signUpLayer pop_addAnimation:left forKey:@"signUpBtnAnim"];
    [loginLayer pop_addAnimation:left forKey:@"animation"];
    [facebookLayer pop_addAnimation:right forKey:@"something"];
    
    UIImage *blurred = nil;
    
    blurred = [self.mainImage.image applyBlurWithRadius:2 tintColor:[UIColor colorWithWhite:1 alpha:0.05] saturationDeltaFactor:1 maskImage:nil];
    self.mainImage.image = blurred;
}

@end
