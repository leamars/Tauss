//
//  SignUpOptViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "SignUpOptViewController.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"


typedef enum {
    FromCameraButton = 0,
    FromPhotoLibrary
}SourceType;

@interface SignUpOptViewController () {
    NSString *firstName;
    NSString *lastName;
    NSNumber *phoneNumber;
    PFUser *user;
    UIImage *profileImage;
    BOOL optional;
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
    
    self.firstNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name (optional)"
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.lastNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name (optional)"
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone # (optional)"
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    NSString *profilePictureString = [[PFUser currentUser] objectForKey:@"profilePicURL"];
    //NSString *ppS = [NSString stringWithFormat:@"%@%@", profilePictureString, @"?width=200&height=200"];
    if (profilePictureString) {
        NSURL *profileImageURL = [NSURL URLWithString:profilePictureString];
    
        NSData *imageData = [NSData dataWithContentsOfURL:profileImageURL];
        self.profilePictureButton.imageView.image = [UIImage imageWithData:imageData];
    
        self.profilePictureButton.imageView.layer.cornerRadius = 58;
        self.profilePictureButton.imageView.layer.masksToBounds = YES;
    }
    
    NSLog(@"VIEW CONTROLLERS IN OPT SIGN UP %@", self.navigationController.viewControllers);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (user[@"firstName"]) {
        self.firstNameField.text = user[@"firstName"];
    }
    
    if (user[@"lastName"]) {
        self.lastNameField.text = user[@"lastName"];
    }
    
    if (user[@"profilePicUrl"]) {
        NSString *profilePictureString = [[PFUser currentUser] objectForKey:@"profilePicURL"];
        //NSString *ppS = [NSString stringWithFormat:@"%@%@", profilePictureString, @"?width=200&height=200"];
        NSURL *profileImageURL = [NSURL URLWithString:profilePictureString];
        
        NSData *imageData = [NSData dataWithContentsOfURL:profileImageURL];
        self.profilePictureButton.imageView.image = [UIImage imageWithData:imageData];
        
        self.profilePictureButton.layer.cornerRadius = 58;
        self.profilePictureButton.layer.masksToBounds = YES;
    }
    
    self.firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.lastNameField) {
        
        [self saveData];
        [self continue:self.continueButton];
        return YES;
    }
    else {
        [textField resignFirstResponder];
        [self.lastNameField becomeFirstResponder];
    }
    
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}

- (void) saveData {
    
    if (!(firstName) || !(lastName)) {
        firstName = self.firstNameField.text;
        lastName = self.lastNameField.text;
        user[@"firstName"] = firstName;
        user[@"lastName"] = lastName;
    }

    user[@"phone"] = self.phoneField.text;
    
    [user saveInBackground];
    [self.view endEditing:YES];
}

#pragma mark - Unwind Segue
- (IBAction)unwindToFirstOpt:(UIStoryboardSegue *)unwindSegue {
}

#pragma mark - Image Picker Methods

- (IBAction)assignProfiePicture:(id)sender {
    
    UIActionSheet *pictureActionSheet = [[UIActionSheet alloc] initWithTitle:@"From?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Picture", @"Choose Existing", nil];
    
    pictureActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [pictureActionSheet showInView:self.view];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (picker.editingMode == DZNPhotoEditViewControllerCropModeCircular) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        DZNPhotoEditViewController *photoEditViewController = [[DZNPhotoEditViewController alloc] initWithImage:image cropMode:DZNPhotoEditViewControllerCropModeCircular];
        [picker pushViewController:photoEditViewController animated:YES];
    }
    else {
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            UIImage *image = info[UIImagePickerControllerEditedImage];
            profileImage = [self resizeImage:image toWidth:200 andHeight:200];
            self.profilePictureButton.imageView.image = profileImage;
            
            if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
            
            if (profileImage) {
                NSLog(@"Uploading profile pic!!");
                NSData *imageData = UIImagePNGRepresentation(profileImage);
                PFFile *imageFile = [PFFile fileWithName:@"profilePic.png" data:imageData];
                
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser[@"profilePicURL"] = imageFile.url;
                    [currentUser saveEventually];
                }];
            }
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    self.profilePictureButton.layer.cornerRadius = 58;
    self.profilePictureButton.layer.masksToBounds = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case FromCameraButton:
            [self shootPicture];
            break;
        case FromPhotoLibrary:
            [self selectExistingPicture];
            break;
            
        default:
            break;
    }
}

#pragma mark - Image Picking Methods

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.navigationBar.tintColor = [UIColor redColor];
    self.imagePickerController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor redColor]};
    
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    self.imagePickerController.editingMode = DZNPhotoEditViewControllerCropModeCircular;
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePickerController.sourceType = sourceType;
        self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing media" message:@"Device doesn't support that media source."  delegate:nil
                                              cancelButtonTitle:@"Drat!"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)shootPicture
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)selectExistingPicture
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

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

#define ACCEPTABLE_CHARECTERS @"abcdefghijklmnopqrstuvwxyz"

- (void) animateTextField: (UITextField *)textField up: (BOOL) up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    const int movementDistanceTwo = 50;
    
    int movement = (up ? -movementDistance : movementDistance);
    int movementTwo = (up ? -movementDistanceTwo : movementDistanceTwo);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.phoneField.frame = CGRectOffset(self.phoneField.frame, 0, movement);
    self.firstNameField.frame = CGRectOffset(self.firstNameField.frame, 0, movement);
    self.lastNameField.frame = CGRectOffset(self.lastNameField.frame, 0, movement);
    self.separatorOne.frame = CGRectOffset(self.separatorOne.frame, 0, movement);
    self.separatorTwo.frame = CGRectOffset(self.separatorTwo.frame, 0, movement);
    self.profilePictureButton.frame = CGRectOffset(self.profilePictureButton.frame, 0, movementTwo);
    
    [UIView commitAnimations];
}

// automatically add hyphens in phone number
// http://stackoverflow.com/questions/6968331/ios-automatically-add-hyphen-in-text-field

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // All digits entered
    if (textField == self.phoneField) {
        if (range.location == 12) {
            return NO;
        }
    
        // Reject appending non-digit characters
        if (range.length == 0 &&
            ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
    
        // Auto-add hyphen before appending 4rd or 7th digit
        if (range.length == 0 &&
            (range.location == 3 || range.location == 7)) {
            textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
            return NO;
        }
    
        // Delete hyphen when deleting its trailing digit
        if (range.length == 1 &&
            (range.location == 4 || range.location == 8))  {
            range.location--;
            range.length = 2;
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
        }
    
    return YES;
}

@end
