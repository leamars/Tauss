//
//  MainViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

// Outlets
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *secondContainerView;
@property (weak, nonatomic) IBOutlet UIButton *flipImageButton;

@property (nonatomic, strong) UIImageView *frontView;
@property (nonatomic, strong) UIImageView *backView;

// Actions
- (IBAction)flipImage:(id)sender;

@end
