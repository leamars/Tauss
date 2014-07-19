//
//  SettingsViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    
    self.nameLabel.text = [[PFUser currentUser] objectForKey:@"fullName"];
    self.emailLabel.text = [[PFUser currentUser] objectForKey:@"email"];
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

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected: %@", indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
            
        case 0:
            
            switch(indexPath.row) {
                    
                case 4: {
                    [PFUser logOut];
                    // Load back the main. There might be the instance that it isn't there? Or should it always be there? Perhaps?
                    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        installation[@"owner"] = [NSNull null];
                        [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"Installation from logout saved");
                            } else {
                                NSLog(@"Not saved: %@", [error localizedDescription]);
                            }
                        }];
                    }];
                    break;
                }
                default: {
                    break;
                }
            }
            
        case 1:
            
            switch (indexPath.row) {
                case 0: {
                    // Terms of use
                    NSLog(@"TERMS");
                    break;
                }
                    
                case 1: {
                    NSLog(@"PRIVACY");
                    break;
                }
                    
                case 2: {
                    NSLog(@"ACKNOWLEDGEMENTS");
                    break;
                }
                case 3: {
                    //Contact us
                    NSLog(@"Contact us");
                    [self contactUs];
                }
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - Helper Methods

- (void)contactUs
{
    if ([MFMailComposeViewController canSendMail] ) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.navigationBar.tintColor = [UIColor blueColor];
        controller.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
        
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Pass It - Feedback!"];
        //[controller setMessageBody:@"I've been using Voyse since forever!" isHTML:NO];
        [controller setToRecipients:@[@"passit@gmail.com"]];
        if (controller)
            [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}



@end
