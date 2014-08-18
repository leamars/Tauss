//
//  SignUpOptViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpOptViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *profilePictureButton;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIView *separatorOne;
@property (weak, nonatomic) IBOutlet UIView *separatorTwo;

// Actions
- (IBAction)continue:(id)sender;
- (IBAction)assignProfiePicture:(id)sender;


@end
