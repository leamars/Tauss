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
#import "SVProgressHUD.h"


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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (user[@"firstName"]) {
        self.firstNameField.text = user[@"firstName"];
    }
    
    if (user[@"lastName"]) {
        self.lastNameField.text = user[@"lastName"];
    }
    
    self.profilePictureButton.imageView.layer.cornerRadius = 45;
    self.profilePictureButton.imageView.layer.masksToBounds = YES;
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
    
    if (!(firstName) || !(lastName)) {
        firstName = self.firstNameField.text;
        lastName = self.lastNameField.text;
        user[@"firstName"] = firstName;
        user[@"lastName"] = lastName;
    }
    
    int phoneNum = [self.phoneField.text intValue];
    phoneNumber = [NSNumber numberWithInt:phoneNum];

    user[@"phone"] = phoneNumber;
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    if (textField == self.firstNameField || textField == self.lastNameField) {
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
}

@end
