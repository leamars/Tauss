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
    // tags that appear on the view
    NSMutableArray *tags;
    PFObject *userContent;
    NSData *contentData;
    NSMutableArray *userGeneratedContent;
    // array of preset tags displayed on the view
    NSMutableArray *presetTags;
    // for comparison with parse tags
    NSMutableArray *parseTags;
    // unique tags not on parse yet
    NSMutableArray *uniqueTags;
    NSMutableArray *toRemove;
    NSMutableArray *finalUsers;
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
    finalUsers = [NSMutableArray new];
    
    [self getCurrentLocation];
    
    self.broadcast.alpha = 0;
    
    // LOCATION STUFF
    locationManager = [[CLLocationManager alloc] init];
    // grab image from previous view
    self.contentImageView.image = self.receivedImage;
    
    self.tagField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add tags..."
                                                                          attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // seting up tag view
    tags = [NSMutableArray new];
    parseTags = [NSMutableArray new];
    uniqueTags = [NSMutableArray new];
    toRemove = [NSMutableArray new];
    [self setUpTags];
    [self tagsForPhoto];
    
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
    
    if ([userContent objectForKey:@"contentQueue"]) {
        userGeneratedContent = [[NSMutableArray alloc] initWithArray:[userContent objectForKey:@"contentQueue"]];
    }
    else {
        userGeneratedContent = [NSMutableArray new];
    }
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hide old HUD, show completed HUD (see example for code)
            
            // Create a PFObject around a PFFile and associate it with the current user
            [userContent setObject:imageFile forKey:@"file"];
            [userContent setObject:[NSNumber numberWithInt:0] forKey:@"passes"];
            [userContent setObject:cityArray forKey:@"cityCount"];
            [userContent setObject:countryArray forKey:@"countryCount"];
            [userContent setObject:imageFile.url forKey:@"contentURL"];
            [userContent setValue:[NSNumber numberWithInt:1] forKey:@"pass"];
            [userContent setObject:@"bryce" forKey:@"submitter"];
            
            // TO DO - what is the movement array? Adding location to things??
            
            // Set the access control list to current user for security purposes
            // userContent.ACL = [PFACL ACLWithUser:currentUser];
            PFACL *contentACL = [PFACL ACL];
            [contentACL setPublicWriteAccess:YES];
            [contentACL setPublicReadAccess:YES];
            userContent.ACL = contentACL;
            
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
                                 [self passContentWithId:[userContent objectId] andTags:tags toNumOfPeople:1 to:[NSArray new] withBroadcastOn:YES andCaption:@"Whateverr"];
                                 [SVProgressHUD dismiss];
                                 [self performSelector:@selector(popTagView) withObject:nil afterDelay:0.6];
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
                        //[SVProgressHUD dismiss];
                    }
                    else{
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        [SVProgressHUD dismiss];
                    }
                }];
            }];
            
            
            [userContent setObject:[currentUser objectId] forKey:@"createdBy"];
            
            [userContent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Photo saved entirely!");
                    
                    //[self broadcasted];
                    //[SVProgressHUD dismiss];
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
    
    PFQuery *tagQuery = [PFQuery queryWithClassName:@"Tag"];
    NSLog(@"parse tags: %@", parseTags);
    [tagQuery whereKey:@"name" containedIn:parseTags];
    [tagQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"ERROR: There was an error with the Query for Content!");
        } else {
            NSLog(@"ALL THE TAGS: %@", objects);
            for (int i = 0; i < [objects count]; i++) {
                int used = [[objects[i] valueForKey:@"timesUsed"] intValue];
                used++;
                PFObject *tag = [PFObject objectWithClassName:@"Tag"];
                tag = objects[i];
                [tag setValue:[NSNumber numberWithInt:used] forKey:@"timesUsed"];
                [tag saveInBackground];
            }
        }
    }];
    
    // to do - improve this search query by better parameters
    PFQuery *uniqueQuery = [PFQuery queryWithClassName:@"Tag"];
    [uniqueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            toRemove = [objects valueForKey:@"name"];
            NSLog(@"BEFORE IN UNIQUE TAGS: %@", uniqueTags);
            [uniqueTags removeObjectsInArray:toRemove];
            
            NSLog(@"AFTER IN UNIQUE TAGS: %@", uniqueTags);
            for (int i = 0; i < [uniqueTags count]; i++) {
                PFObject *uniqueTag = [PFObject objectWithClassName:@"Tag"];
                [uniqueTag setObject: uniqueTags[i] forKey:@"name"];
                [uniqueTag setObject:[NSNumber numberWithInt:1] forKey:@"timesUsed"];
                [uniqueTag saveInBackground];
            }
            
        }
        else {
            NSLog(@"Houston... we have a problem :(");
        }
    }];
    
}

#pragma mark - taglist delegate

- (void) setUpTags {
    
    CGSize viewSize = self.view.bounds.size;
    
    presetTags = [[NSMutableArray alloc] initWithObjects:@"Technology", @"Photography", @"Business", @"Sports", @"Style", @"Travel", @"Music", @"Food", @"Science", @"Nature", nil];
    
    _tagList = [[DWTagList alloc] initWithFrame:CGRectMake(20.0, viewSize.height - 200, self.view.bounds.size.width-40.0f, 50.0f)];
    [_tagList setAutomaticResize:YES];
    [_tagList setTags:presetTags];
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

- (void) tagsForPhoto {
    CGSize viewSize = self.view.bounds.size;
    
    _photoTags = [[DWTagList alloc] initWithFrame:CGRectMake(20.0, viewSize.height - 100, self.view.bounds.size.width-40.0f, 50.0f)];
    [_photoTags setAutomaticResize:YES];
    [_photoTags setTags:tags];
    [_photoTags setTagDelegate:self];
    
    // Customisation
    [_photoTags setCornerRadius:4.0f];
    [_photoTags setBorderColor:[UIColor colorWithWhite:1 alpha:0.5].CGColor];
    [_photoTags setTagHighlightColor:[UIColor taussBlue]];
    [_photoTags setTextShadowColor:[UIColor clearColor]];
    [_photoTags setBorderWidth:0.0f];
    [_photoTags setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:14.0]];
    [_photoTags setTagBackgroundColor:[UIColor taussBlue]];
    
    [self.view addSubview:_photoTags];
    
    // tag array for parse
    tagArray = [NSMutableArray new];
}

- (void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex {
    
    if ([presetTags objectAtIndex:tagIndex] == tagName) {
        [parseTags addObject:tagName];
        //[tags addObject:[NSString stringWithFormat:@"%@ x", tagName]];
        [self.photoTags setTags:tags];
    }
    else {
        [parseTags removeObject:tagName];
        [tags removeObject:tagName];
        [self.photoTags setTags:tags];
    }
    
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
            [tags addObject:[[NSString stringWithFormat:@"%@ x", stringArr[i]] capitalizedString]];
            [uniqueTags addObject:[stringArr[i] capitalizedString]];
            [parseTags addObject:[stringArr[i] capitalizedString]];
        }
        //[tagArray addObjectsFromArray:stringArr];
    }
    [self.tagField setText:@""];
    [self.photoTags setTags:tags];
    
    //[userContent setObject:tagArray forKey:@"tags"];
    
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
    self.photoTags.frame = CGRectOffset(self.photoTags.frame, 0, movement);
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

- (void) popTagView {
    [self.navigationController popViewControllerAnimated:YES];
}

// PASS METHOD

- (void) passContentWithId: (NSString *)contentId andTags:(NSArray *)contentTags toNumOfPeople:(int)numOfPeople to:(NSArray *) receivers withBroadcastOn:(BOOL) broadcast andCaption:(NSString*) caption {
	
    finalUsers = [NSMutableArray new];
    
	//Create a list with objectIds of receiver
	NSMutableArray * receiverObjectIds = [NSMutableArray new];
	for (PFUser *user in receivers) {
		[receiverObjectIds addObject: [user objectId]];
	}
    
    if (broadcast) {
        
        //Find user with similar interests which has not received the content yet
        PFQuery *query = [PFUser query];
        [query whereKey:@"contentReceived" notEqualTo:contentId];
        [query whereKey:@"passes" notEqualTo:contentId];
        [query whereKey:@"trashes" notEqualTo:contentId];
        [query whereKey:@"tags" containedIn:contentTags]; // TO DO
        [query whereKey:@"objectId" notEqualTo:[currentUser objectId]];
        //Exclude reciver list
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            int size = [objects count];
            
            // Scenario 1: amount of random users with interest (ri) is equal or more than the amount of people who have to receive the content.
            // No real random (rr) users have to be added to the list.
            
            if (size >= numOfPeople) {
                while ([finalUsers count] < numOfPeople) {
                    for (int i = 0; i < numOfPeople; i++) {
                        int random = arc4random() % size;
                        if (![finalUsers containsObject:objects[random]]) {
                            [finalUsers addObject:objects[random]];
                        }
                        else {
                            i--;
                        }
                    }
                }
                
                // Add results to receiver list
                if ([receivers count] > 0) {
                    [finalUsers addObjectsFromArray:receivers];
                    // JUST FOR DEMO - DON'T ACTUALLY REMOVE
                    for (PFUser *user in finalUsers) {
                        if ([user[@"email"] isEqualToString:currentUser[@"email"]]) {
                            [finalUsers removeObject:user];
                        }
                    }
                }
                
                //TO DO send to users here
                for (PFUser *user in finalUsers) {
                    NSLog(@"User is: %@", user[@"email"]);
                }
            }
            
            // Scenario 2: amount of found users is less than the number of interested users.
            // real random (rr) users have to be added to the finalUsers list, until it is full. Full = numbers of finalUsers = numPeople
            
            else {
                [finalUsers addObjectsFromArray:objects];
                
                PFQuery *newQuery = [PFUser query];
                [query whereKey:@"contentReceived" notEqualTo:contentId];
                [newQuery whereKey:@"tags" notContainedIn:contentTags];
                [newQuery whereKey:@"passes" notEqualTo:contentId];
                [newQuery whereKey:@"trashes" notEqualTo:contentId];
                [query whereKey:@"objectId" notEqualTo:[currentUser objectId]];
                
                // Exclude receiver list
                [newQuery setLimit:((numOfPeople - [objects count]) *5)];
                
                [newQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    int size = [objects count];
                    int start = [finalUsers count];
                    
                    // If the number of finalUsers + the found users can serve the needed number of users (numPeople),
                    // finalUsers can be filled up until numPeople is reached
                    if ((size + start) >= numOfPeople) {
                        for (int i = start; i < numOfPeople; i++) {
                            int random = arc4random() % size;
                            if (![finalUsers containsObject:objects[random]]) {
                                [finalUsers addObject:objects[random]];
                            }
                            else {
                                //i--;
                            }
                        }
                    }
                    else {
                        [finalUsers addObjectsFromArray:objects];
                    }
                    
                    if ([receivers count] > 0) {
                        [finalUsers addObjectsFromArray:objects];
                    }
                    
                    for (PFUser *user in finalUsers) {
                        if ([user isEqual:currentUser]) {
                            [finalUsers removeObject:user];
                        }
                    }
                    [self pushContentWithContentId:[userContent objectId] toReceivers:finalUsers withCaption:@""];
                    
                    for (PFUser *user in finalUsers) {
                        NSLog(@"Parse user: %@", user[@"email"]);
                    }
                }];
                
            }
        }];
    }
}

- (void) pushContentWithContentId: (NSString *)contentId toReceivers:(NSArray *)receivers withCaption:(NSString *)caption {
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" containedIn:receivers];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:contentId, @"contentId", @"Increment", @"badge",  @"New great Tauss content just for you!", @"alert", caption, @"caption", @"Realization.aif", @"sound", nil];
    PFPush *push = [PFPush new];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}

@end