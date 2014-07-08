//
//  SignUpOptViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "SignUpOptViewController.h"
#import <Parse/Parse.h>

@interface SignUpOptViewController () {
    NSString *firstName;
    NSString *lastName;
    NSNumber *phoneNumber;
    PFUser *user;
}

@end

@implementation SignUpOptViewController

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
    
    user = [PFUser currentUser];
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

- (IBAction)continue:(id)sender {
    [self saveData];
}

#pragma mark - textfield methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get rid of keyboard when you touch anywhere on the screen
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self saveData];
    [textField resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (void) saveData {
    firstName = self.firstNameField.text;
    lastName = self.lastNameField.text;
    int phoneNum = [self.phoneField.text intValue];
    phoneNumber = [NSNumber numberWithInt:phoneNum];
    
    user[@"firstName"] = firstName;
    user[@"lastName"] = lastName;
    user[@"phone"] = phoneNumber;
    
    NSLog(@"phone nubmer: %@", phoneNumber);
    
    [user saveInBackground];
    [self.view endEditing:YES];
}

#pragma mark - Unwine Segue
- (IBAction)unwindToFirstOpt:(UIStoryboardSegue *)unwindSegue {
}

@end
