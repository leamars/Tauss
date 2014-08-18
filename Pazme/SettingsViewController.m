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
#import "UIColor+Tauss.h"

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
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundAlt"]];
    
    self.broadcastSwitch.onTintColor = [UIColor taussBlue];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self customizeCells];
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

#pragma mark - UISwtich Methods


#pragma mark - UITableView Delegate

- (void) customizeCells {
    [self.broadcastCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.broadcastCellLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:166.0/255.0 blue:207.0/255.0 alpha:1];
    
    [self.nameCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.nameCellLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:171.0/255.0 blue:201.0/255.0 alpha:1];
    
    [self.emailCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.emailCellLabel.textColor = [UIColor colorWithRed:72.0/255.0 green:176.0/255.0 blue:195.0/255.0 alpha:1];
    
    [self.logoutCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.logoutCellLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:181.0/255.0 blue:189.0/255.0 alpha:1];
    
    [self.termsCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.termsCellLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:186.0/255.0 blue:183.0/255.0 alpha:1];
    
    [self.privacyCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.privacyCellLabel.textColor = [UIColor colorWithRed:84.0/255.0 green:191.0/255.0 blue:177.0/255.0 alpha:1];
    
    [self.acknCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.acknCellLabel.textColor = [UIColor colorWithRed:88.0/255.0 green:196.0/255.0 blue:171.0/255.0 alpha:1];
    
    [self.contactCellLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Regular" size:20.0]];
    self.contactCellLabel.textColor = [UIColor colorWithRed:92.0/255.0 green:201.0/255.0 blue:165.0/255.0 alpha:1];
    
    [self.nameLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:16.0]];
    self.nameLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1];
    
    [self.emailLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:16.0]];
    self.emailLabel.textColor = [UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected: %@", indexPath);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
            
        case 0:
            
            switch(indexPath.row) {
                    
                case 3: {
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
        [controller setToRecipients:@[@"passit@gmail.com"]]; //TO DO: Get an actual email
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



- (IBAction)switchChanged:(id)sender {
    UISwitch *switcher = (UISwitch*)sender;
    BOOL value = switcher.on;
    
    // Broadcast initially ON == 1
    if (value == true) {
        // turn broadcast feature on
    }
    else {
        // turn it off
    }
}
@end
