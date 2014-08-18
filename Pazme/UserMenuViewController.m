//
//  UserMenuViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "UserMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import <Parse/Parse.h>

@interface UserMenuViewController ()
{
    PFUser *currentUser;
}

@end

@implementation UserMenuViewController

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
    
    self.slidingViewController.anchorRightRevealAmount = 250.0;
    
    currentUser = [PFUser currentUser];
    
    NSString *profilePictureString = [[PFUser currentUser] objectForKey:@"profilePicURL"];
    NSLog(@"What is the URL: %@", profilePictureString);
    NSURL *url = [NSURL URLWithString:profilePictureString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *profileImage = [UIImage imageWithData:data];
    
    NSLog(@"Profile Image: %@", profileImage);
    
    if (profileImage) {
    
        [self.profilePictureImageView setImage:profileImage];
        [self resizeImage:self.profilePictureImageView.image toWidth:180 andHeight:180];

    }
    else {
//        UIView *noProfilePicture = [UIView new];
//        [noProfilePicture view];
//        [self.profilePictureImageView addSubview:[UIImage imageNamed:@"camera"]];
    }
    
    self.profilePictureImageView.layer.cornerRadius = 63;
    self.profilePictureImageView.layer.masksToBounds = YES;
    
    self.profilePicBg.layer.cornerRadius = 70;
    self.profilePicBg.layer.masksToBounds = YES;
    
    [self resizeImage:self.profilePictureImageView.image toWidth:200 andHeight:200];
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

#pragma mark - ECSliding Methods

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue
{
    NSLog(@"We unwound. Whoo.");
}

- (IBAction)goToSettings:(id)sender {
    [self performSegueWithIdentifier:@"toSettings" sender:sender];
}

- (IBAction)goToProfile:(id)sender {
    [self performSegueWithIdentifier:@"toProfile" sender:sender];
}

- (IBAction)goToFriends:(id)sender {
    [self performSegueWithIdentifier:@"toMain" sender:sender];
}

- (IBAction)goToActivity:(id)sender {
    [self performSegueWithIdentifier:@"toMain" sender:sender];
}

#pragma mark - Helper Methods

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}
@end
