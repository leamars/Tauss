//
//  TagPhotoViewController.m
//  Pazme
//
//  Created by Lea Marolt on 8/17/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "TagPhotoViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "UIColor+Tauss.h"

@interface TagPhotoViewController ()
{
    PFUser *currentUser;
    NSMutableArray *tagArray;
    CLLocation *currentLocation;
    NSString *country;
    NSString *city;
    NSMutableArray *cityArray;
    NSMutableArray *countryArray;
    NSMutableArray *tags;
    PFObject *userContent;
    NSData *contentData;
}

@end

@implementation TagPhotoViewController

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
    
    cityArray = [NSMutableArray new];
    countryArray = [NSMutableArray new];
    
    currentUser = [PFUser currentUser];
    userContent = [PFObject objectWithClassName:@"Content"];
    
    self.broadcast.alpha = 0;
    
    // LOCATION STUFF
    locationManager = [[CLLocationManager alloc] init];
    // grab image from previous view
    self.contentImageView.image = self.receivedImage;
    
    self.tagField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add tags..."
                                                                               attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // seting up tag view
    [self setUpTags];
    
    // set up image to save on parse
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [self.contentImageView.image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    contentData = UIImagePNGRepresentation(smallImage);
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

- (void) uploadImage: (NSData *) imageData {
    
    [self showHud];
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            [userContent setObject:imageFile forKey:@"file"];
            [userContent setObject:[NSNumber numberWithInt:0] forKey:@"passes"];
            [userContent setObject:cityArray forKey:@"cityCount"];
            [userContent setObject:countryArray forKey:@"countryCount"];
            
            // TO DO - what is the movement array? Adding location to things??
            
            // Set the access control list to current user for security purposes
            userContent.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                if (!error) {
                    // do something with the new geoPoint
                    [userContent setObject:geoPoint forKey:@"createdIn"];
                    
                    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
                    
                    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
                    
                    [reverseGeocoder reverseGeocodeLocation:myLocation completionHandler:^(NSArray *placemarks, NSError *error)
                     {
                         //NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                         if (error){
                             //NSLog(@"Geocode failed with error: %@, and the location was: %@", error, myLocation);
                             return;
                         }
                         
                         CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
                         NSString *countryCode = myPlacemark.ISOcountryCode;
                         country = myPlacemark.country;
                         [countryArray addObject:country];
                         // NSLog(@"My country code: %@ and countryName: %@", countryCode, country);
                         
                         city = myPlacemark.addressDictionary[@"City"];
                         [cityArray addObject:city];
                         
                         [userContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                             if (!error) {
                                 NSLog(@"City & Country saved!!");
                                 [SVProgressHUD dismiss];
                                 
                             }
                             else{
                                 // Log details of the failure
                                 NSLog(@"Error: %@ %@", error, [error userInfo]);
                                 [SVProgressHUD dismiss];
                             }
                         }];
                         
                     }];
                }
                
                [userContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"GeoLocation saved!!");
                        [SVProgressHUD dismiss];
                    }
                    else{
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        [SVProgressHUD dismiss];
                    }
                }];
            }];
            
            
            PFUser *user = [PFUser currentUser];
            [userContent setObject:user forKey:@"createdBy"];
            
            [userContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Photo saved entirely!");
                    [self broadcasted];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            [SVProgressHUD dismiss];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
    }];

}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    NSLog(@"WHAT IS MY CURRENT LOCATION: %@", currentLocation);
    
    // GET COUNTRY AND CITY
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
         if (error){
             NSLog(@"Geocode failed with error: %@, and the location was: %@", error, currentLocation);
             return;
         }
         
         NSLog(@"Received placemarks: %@", placemarks);
         
         CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
         NSString *countryCode = myPlacemark.ISOcountryCode;
         country = myPlacemark.country;
         [countryArray addObject:country];
         // NSLog(@"My country code: %@ and countryName: %@", countryCode, country);
         
         city = myPlacemark.addressDictionary[@"City"];
         [cityArray addObject:city];
         
         NSLog(@"Cities & countries: %@, %@", cityArray, countryArray);
         
     }];
    
    [locationManager stopUpdatingLocation];
}

- (void) getCurrentLocation {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (void) getCurrentCountryAndCity {
}

- (void) showHud {
    [[SVProgressHUD appearance] setTintColor:[UIColor redColor]];
    [[SVProgressHUD appearance] setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
}

- (IBAction)broadcastImage:(id)sender {
    [self uploadImage:contentData];
}

#pragma mark - taglist delegate

- (void) setUpTags {
    
    CGSize viewSize = self.view.bounds.size;
    
    tags = [NSMutableArray new];
    
    _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(20.0, viewSize.height - 100, self.view.bounds.size.width-40.0f, 50.0f)];
    [_tagList setAutomaticResize:YES];
    [_tagList setTags:tags];
    [_tagList setTagDelegate:self];
    
    // Customisation
    [_tagList setCornerRadius:4.0f];
    [_tagList setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    [_tagList setTagHighlightColor:[UIColor taussBlue]];
    [_tagList setTextShadowColor:[UIColor clearColor]];
    [_tagList setBorderWidth:0.0f];
    [_tagList setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:14.0]];
    
    [self.view addSubview:_tagList];
    
    // tag array for parse
    tagArray = [NSMutableArray new];
}

- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:[NSString stringWithFormat:@"You tapped tag %@", tagName]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    
    NSLog(@"TAG VIEW IS: %d", tagIndex);
    
    [alert show];
}

#pragma mark - UITextFieldDelegate Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // get rid of keyboard when you touch anywhere on the screen
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if ([[self.tagField text] length]) {
        NSString *tag = [self.tagField text];
        NSArray *stringArr = [tag componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"What's in the string array: %@", stringArr);
        for (int i = 0; i < stringArr.count; i++) {
            [tags addObject:stringArr[i]];
            NSLog(@"am i getting here...? %@", stringArr[i]);
        }
        [tagArray addObjectsFromArray:stringArr];
    }
    [self.tagField setText:@""];
    [_tagList setTags:tags];
    
    [userContent setObject:tagArray forKey:@"tags"];
    
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

- (void) animateTextField: (UITextField *)textField up: (BOOL) up
{
    const int movementDistance = 220; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.tagList.frame = CGRectOffset(self.tagList.frame, 0, movement);
    self.tagField.frame = CGRectOffset(self.tagField.frame, 0, movement);
    self.backgroundTagView.frame = CGRectOffset(self.backgroundTagView.frame, 0, movement);
    [UIView commitAnimations];
}

- (void) broadcasted {
        [UIView animateWithDuration:0.25
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.broadcast.alpha = 0.5;
                         }
                         completion:^(BOOL finished){
                             // Wait one second and then fade in the view
                             [UIView animateWithDuration:0.25
                                                   delay: 0.6
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.broadcast.alpha = 0;
                                              }
                                              completion:nil];
                         }];
}

@end
