//
//  UserMenuViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMenuViewController : UIViewController

// Outlets
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
- (IBAction)goToSettings:(id)sender;
- (IBAction)goToProfile:(id)sender;
- (IBAction)goToFriends:(id)sender;
- (IBAction)goToActivity:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *profilePicBg;

// Actions
@end
