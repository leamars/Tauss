//
//  MainViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "MainViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import <Parse/Parse.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import <QuartzCore/QuartzCore.h>
#import "TagPhotoViewController.h"
#import "OCMapViewSampleHelpAnnotation.h"
#import "UIColor+Tauss.h"
#import "PazmeDataModel.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

static CGFloat kDEFAULTCLUSTERSIZE = 0.5;
static NSString *const kTYPE1 = @"Banana";
static NSString *const kTYPE2 = @"Orange";

@interface MainViewController () <DBCameraViewControllerDelegate> {
    BOOL up;
    UIImage *imageToSend;
    OCAnnotation *clusterAnnotation;
    NSMutableArray *stockImages;
    int pressNum;
    int numSwiped;
    NSArray *countriesArray;
    NSArray *longitudeLatitude;
    int numAfterWalkthrough;
    PFUser *currentUser;
}

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        stockImages = [NSMutableArray arrayWithArray:[self defaultPhotos]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"THIS \n IS \n EXTREMELY \n IMPORTANT!!! %ld", (long)[[UIApplication sharedApplication] applicationIconBadgeNumber]);
    [self configureECSlidingController];
    currentUser = [PFUser currentUser];
    
    // SAVE THE USER IN THE INSTALLATION
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
    pressNum = 0;
    numSwiped = 0;
    numAfterWalkthrough = 0;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [self randomizeMetricsForPhoto];
    
    // MAP STUFF
    
    self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    
    // You can customize MDCSwipeToChooseView using MDCSwipeToChooseViewOptions.
    
    // SWIPE VIEW PROGRAMATICALLY - [self.swipeToChooseView mdc_swipe:MDCSwipeDirectionLeft];
    
    // You can customize MDCSwipeToChooseView using MDCSwipeToChooseViewOptions.
//    stockImages = [[NSMutableArray alloc] initWithArray:[self defaultImages]];
//    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
//        //self.metricsView.hidden = YES;
//        [self checkForContentByUser:[currentUser objectId]];
////        [self viewsToSwipe];
//    }
//    else {
//        [self viewsToSwipe];
//    }
    
    
    // CHECK IF I GET THE PHOTO HERE!
    
//    [self pushContentWithContentId:@"nTIRFvECzh" toReceivers:[NSArray arrayWithObjects:@"bryce@bryce.com", @"leyamars@gmail.com", nil] withCaption:@"BOO!"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"] == NO) {
        [self viewsToSwipe];
    }
    
//    // Create our Installation query
//    PFQuery *pushQuery = [PFInstallation query];
//    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
//    
//    // Send push notification to query
//    [PFPush sendPushMessageToQueryInBackground:pushQuery
//                                   withMessage:@"Hello World!"];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self constructCountries];
    
    stockImages = [[NSMutableArray alloc] initWithArray:[self defaultImages]];
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        //self.metricsView.hidden = YES;
        [self checkForContentByUser:[currentUser objectId]];
        //        [self viewsToSwipe];
    }
    else {
        [self viewsToSwipe];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) constructCountries {
    countriesArray = [[NSArray alloc] initWithObjects:@"Auckland, New Zealand", @"Mozirje, Slovenia", @"Madeira, Portugal", @"Berlin, Germany", @"Utrecht, Netherlands", @"Grinnell, USA", @"Seattle, USA", @"London, UK", @"Dublin, Ireland", @"Sydney, Australia", @"Novi Grad, Croatia", @"Rome, Italy", @"Hvar, Croatia", @"Budapest, Hungary", @"Vienna, Austria", @"Brasilia, Brasil", @"Mexico City, Mexico", @"Chile, Santiago", @"Ghana, Accra", @"Azerbaijan, Baku", nil];
    
    longitudeLatitude = [[NSArray alloc] initWithObjects:
    @[@36.8404, @174.7399],
    @[@46.3333, @14.9667],
    @[@32.6511, @16.9097],
    @[@52.5167, @13.3833],
    @[@52.0833, @5.1167],
    @[@41.7436, @92.7247],
    @[@47.6097, @122.3331],
    @[@51.5072, @0.1275],
    @[@53.3478, @6.2597],
    @[@33.8600, @151.2094],
    @[@45.3167, @13.5500],
    @[@41.9000, @12.5000],
    @[@43.1667, @16.4500],
    @[@47.4925, @19.0514],
    @[@48.2000, @16.3667],
    @[@15.7989, @47.8667],
    @[@19.4333, @99.1333],
    @[@33.4500, @70.6667],
    @[@5.5500, @0.2000],
    @[@33.4500, @70.6667],
                         nil];
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

- (void)configureECSlidingController {
    // setup swipe and button gestures for the sliding view controller
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    //    [[self.navigationController.viewControllers.firstObject view] addGestureRecognizer:self.slidingViewController.panGesture];
    
    // TO DO: Swipe to the right to reveal menu
}

#pragma mark - acquire content

- (NSArray *)getContentToSwipe {
    
    // acquire data
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    return data;
}


- (IBAction)takePhoto:(id)sender {
    [self openCamera];
}

- (IBAction)showMetricsView:(id)sender {
    
    if (pressNum % 2 == 0) {
        [self animateMetrics:YES];
    }
    else {
        [self animateMetrics:NO];
    }
    
    pressNum++;
}

- (void) animateMetrics:(BOOL) direction {
    
    const int movementDistance = 400; // tweak as needed
    const float movementDuration = 0.6f; // tweak as needed
    
    int movement = (direction ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.metricsView.frame = CGRectOffset(self.metricsView.frame, 0, movement);
    self.mapView.frame = CGRectOffset(self.mapView.frame, 0, movement);
    
    [UIView commitAnimations];
}

#pragma mark - Camera methods

- (void) openCamera
{
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [cameraContainer setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    imageToSend = [UIImage new];
    imageToSend = image;
    [self performSegueWithIdentifier:@"tagPhoto" sender:self];
    NSLog(@"BUTTON PRESSED");
    [self dismissCamera:cameraViewController];
}

- (void) dismissCamera:(id)cameraViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"tagPhoto"]){
        
        TagPhotoViewController *tpvc = (TagPhotoViewController *)segue.destinationViewController;
        tpvc.receivedImage = imageToSend;
    }
}

#pragma mark - map methods

- (void)updateOverlays
{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for (OCAnnotation *annotation in self.mapView.displayedAnnotations) {
        if ([annotation isKindOfClass:[OCAnnotation class]]) {
            
            int numOfPins = [annotation.annotationsInCluster count];
           // NSLog(@"WHAT IS THE NUMBER OF ANNOTATIONS IN THIS CLUSTER? %i", numOfPins);
            
            //            if (numOfPins <= 10) {
            //                self.mapView.clusterSize = 0.1;
            //            }
            //
            //            else if (numOfPins > 10 && numOfPins <= 50) {
            //                self.mapView.clusterSize = 0.2;
            //            }
            //
            //            else if (numOfPins > 50 && numOfPins <= 100) {
            //                self.mapView.clusterSize = 0.3;
            //            }
            //
            //            else if (numOfPins > 100 && numOfPins <= 500) {
            //                self.mapView.clusterSize = 0.4;
            //            }
            //
            //            else if (numOfPins > 500 && numOfPins <= 1000) {
            //                self.mapView.clusterSize = 0.5;
            //            }
            //
            //            else if (numOfPins > 1000 && numOfPins <= 2000) {
            //                self.mapView.clusterSize = 0.6;
            //            }
            //
            //            else if (numOfPins > 2000 && numOfPins <= 5000) {
            //                self.mapView.clusterSize = 0.7;
            //            }
            //
            //            else if (numOfPins > 5000 && numOfPins <= 10000) {
            //                self.mapView.clusterSize = 1;
            //            }
            
            // static circle size of cluster
            CLLocationDistance clusterRadius = self.mapView.region.span.longitudeDelta * (numOfPins/250.0) * 111000 / 20.0f;
            clusterRadius = clusterRadius * [self zoomLevel];
            
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:clusterRadius];
            [circle setTitle:@"background"];
            [self.mapView addOverlay:circle];
            
            MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:annotation.coordinate radius:clusterRadius];
            [circleLine setTitle:@"line"];
            [self.mapView addOverlay:circleLine];
            
        }
    }
}

- (double) zoomLevel
{
    CLLocationDegrees longitudeDelta = self.mapView.region.span.longitudeDelta;
    CGFloat mapWidthInPixels = self.mapView.bounds.size.width;
    double zoomScale = longitudeDelta * 85445659.44705395 * M_PI / (180.0 * mapWidthInPixels);
    double zoomer = 20 - log2( zoomScale );
    if ( zoomer < 0 ) zoomer = 0;
    //  zoomer = round(zoomer);
    return zoomer;
}

- (IBAction)addRandom:(id)sender {
    
    NSArray *randomLocations = [[NSArray alloc] initWithArray:[self randomCoordinatesGenerator:10]];
    NSMutableSet *annotationsToAdd = [[NSMutableSet alloc] init];
    
    for (CLLocation *loc in randomLocations) {
        OCMapViewSampleHelpAnnotation *annotation = [[OCMapViewSampleHelpAnnotation alloc] initWithCoordinate:loc.coordinate];
        [annotationsToAdd addObject:annotation];
        
        // add to group if specified
        if (annotationsToAdd.count < (randomLocations.count)/2.0) {
            annotation.groupTag = @"Shared: 56";
        } else {
            annotation.groupTag = @"Shared: 13";
        }
        
    }
    
    [self.mapView addAnnotations:[annotationsToAdd allObjects]];
}

// MY METHODS


- (NSArray *)randomCoordinatesGenerator:(int)numberOfCoordinates
{
    MKCoordinateRegion visibleRegion = self.mapView.region;
    visibleRegion.span.latitudeDelta *= 0.8;
    visibleRegion.span.longitudeDelta *= 0.8;
    
    int max = 9999;
    numberOfCoordinates = MAX(0,numberOfCoordinates);
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // start with top left corner
        CLLocationDistance longitude = visibleRegion.center.longitude - visibleRegion.span.longitudeDelta/2.0;
        CLLocationDistance latitude  = visibleRegion.center.latitude + visibleRegion.span.latitudeDelta/2.0;
        
        // Get random coordinates within current map rect
        longitude += ((arc4random()%max)/(CGFloat)max) * (visibleRegion.span.longitudeDelta);
        latitude  -= ((arc4random()%max)/(CGFloat)max) * (visibleRegion.span.latitudeDelta);
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    return  coordinates;
}


#pragma mark - map delegate
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        
        clusterAnnotation = (OCAnnotation *)annotation;
        
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"ClusterView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ClusterView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        
        // set title
        clusterAnnotation.title = [NSString stringWithFormat:@"Shares: %zd", [clusterAnnotation.annotationsInCluster count]];
        
        
        // set its image
        annotationView.image = [UIImage imageNamed:@"regular.png"];
        
        // change pin image for group
        if (self.mapView.clusterByGroupTag) {
            if ([clusterAnnotation.groupTag isEqualToString:kTYPE1]) {
                annotationView.image = [UIImage imageNamed:@"regular.png"];
            }
            else if([clusterAnnotation.groupTag isEqualToString:kTYPE2]){
                annotationView.image = [UIImage imageNamed:@"regular.png"];
            }
            clusterAnnotation.title = clusterAnnotation.groupTag;
        }
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[OCMapViewSampleHelpAnnotation class]]){
        OCMapViewSampleHelpAnnotation *singleAnnotation = (OCMapViewSampleHelpAnnotation *)annotation;
        annotationView = (MKAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"singleAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:singleAnnotation reuseIdentifier:@"singleAnnotationView"];
            annotationView.canShowCallout = YES;
            annotationView.centerOffset = CGPointMake(0, -20);
        }
        singleAnnotation.title = singleAnnotation.groupTag;
        
        if ([singleAnnotation.groupTag isEqualToString:kTYPE1]) {
            annotationView.image = [UIImage imageNamed:@"regular"];
        }
        else if([singleAnnotation.groupTag isEqualToString:kTYPE2]){
            annotationView.image = [UIImage imageNamed:@"regular"];
        }
    }
    // Error
    else{
        annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:@"errorAnnotationView"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"errorAnnotationView"];
            annotationView.canShowCallout = NO;
            ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorRed;
        }
    }
    
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircle *circle = overlay;
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    
    if ([circle.title isEqualToString:@"background"])
    {
        circleView.fillColor = [UIColor taussBlue];
        circleView.alpha = 0.25;
    }
    else if ([circle.title isEqualToString:@"helper"])
    {
        circleView.fillColor = [UIColor redColor];
        circleView.alpha = 0.25;
    }
    else
    {
        circleView.strokeColor = [UIColor blackColor];
        circleView.lineWidth = 0.5;
    }
    
    return circleView;
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapView doClustering];
    [self updateOverlays];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views;
{
    [self updateOverlays];
}

// SWIPING STUFF

- (NSArray *) defaultPhotos {
    NSMutableArray *photoArray = [NSMutableArray new];
    
    for (int i = 0; i < 20; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i", i]];
        [photoArray addObject:image];
    }
    
    return photoArray;
}

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Couldn't decide, huh?");
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft) {
        // IMPLEMENT TRASH METHOD
        NSLog(@"Photo deleted!");
    } else {
        // IMPLEMENT PASS MATHOD
        NSLog(@"Photo saved!");
    }
    numSwiped++;
    NSLog(@"Num swiped is >= 20: %i", numSwiped);
    numAfterWalkthrough++;
    
    if (numSwiped >= 18) {
        numSwiped = 0;
        [stockImages addObjectsFromArray:[self defaultImages]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"] == NO) {
        if (numAfterWalkthrough >= 3) {
            NSLog(@"Num is >= 4: %i", numAfterWalkthrough);
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        }
    }
    else {
        [self viewsToSwipe];
    }
    
    self.metricsView.hidden = NO;
    
}

- (void) viewsToSwipe {
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.likedText = @"Pass";
    options.likedColor = [UIColor whiteColor];
    options.nopeText = @"Trash";
    options.nopeColor = [UIColor whiteColor];
    options.onPan = ^(MDCPanState *state){
        if (state.thresholdRatio == 1.f && state.direction == MDCSwipeDirectionLeft) {
            NSLog(@"Let go now to delete the photo!");
        }
    };
    
    self.frontView = [[MDCSwipeToChooseView alloc] initWithFrame:self.view.bounds
                                                         options:options];
    self.backView = [[MDCSwipeToChooseView alloc] initWithFrame:self.view.bounds
                                                        options:options];
    
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"] == NO) {
        for (int i = 4; i > 0; i--) {
            MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.view.bounds
                                                                         options:options];
        
            CGRect wholeScreen = CGRectMake(0, 0, 320, 568);
        
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"walkthrough%i", i]];
        
        //        view.imageView.image = [self getSubImageFrom:[self resizeImage:img toWidth:img.size.width/1.5 andHeight:img.size.height/1.5] WithRect:wholeScreen];
        
            view.imageView.image = img;
        
            [self.view insertSubview:view belowSubview:self.metricsView];
        }
    }
    else {
            // NO MORE WALKTHROUGH
        if ([stockImages count] == 0) {
            [self defaultImages];
        }
        
        [self randomizeMetricsForPhoto];
        self.frontView.imageView.image = stockImages[0];
        [self.view insertSubview:self.frontView belowSubview:self.metricsView];
        [stockImages removeObjectAtIndex:0];
        self.backView.imageView.image = stockImages[0];
        [self.view insertSubview:self.backView belowSubview:self.frontView];
        
    }
    
}

// PASS METHOD

- (void) passContentWithId: (NSString *)contentId andTags:(NSArray *)contentTags toNumOfPeople:(int)numOfPeople to:(NSArray *) receivers withBroadcastOn:(BOOL) broadcast andCaption:(NSString*) caption {
	
    NSMutableArray *finalUsers = [NSMutableArray new];
    
	//Create a list with objectIds of receiver
	NSMutableArray * receiverObjectIds = [NSMutableArray new];
	for (PFUser *user in receivers) {
		[receiverObjectIds addObject: [user objectId]];
	}
    
    if (broadcast) {
        
        //Find user with similar interests which has not received the content yet
        PFQuery *query = [PFUser query];
        [query whereKey:@"contentQueue" notEqualTo:contentId];
        [query whereKey:@"passes" notEqualTo:contentId];
        [query whereKey:@"trashes" notEqualTo:contentId];
        [query whereKey:@"tags" containedIn:contentTags]; // TO DO
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
                [newQuery whereKey:@"contentQueue" notEqualTo:contentId];
                [newQuery whereKey:@"tags" notContainedIn:contentTags];
                [newQuery whereKey:@"passes" notEqualTo:contentId];
                [newQuery whereKey:@"trashes" notEqualTo:contentId];
                
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
                                i--;
                            }
                        }
                    }
                    else {
                        [finalUsers addObjectsFromArray:objects];
                    }
                    
                    if (!([receivers count] > 0)) {
                        [finalUsers addObjectsFromArray:objects];
                    }
                    
                    for (PFUser *user in finalUsers) {
                        NSLog(@"Parse user: %@", user[@"email"]);
                    }
                }];
                
            }
        }];
    }
}

- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
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

// CORRECT IMAGES METHODS

- (void)setFrontCardView:(UIImage *)frontCardImage {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontImage.image = frontCardImage;
    self.currentImage = frontCardImage;
}

- (NSArray *)defaultImages {
    // It would be trivial to download these from a web service
    // as needed, but for the purposes of this sample app we'll
    // simply store them in memory.
    
    NSMutableArray *defaultImg = [NSMutableArray new];
    
    for (int i = 20; i > 0; i--) {
        
        CGRect wholeScreen = CGRectMake(0, 0, 320, 568);
        
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i-1", i]];
        
        [defaultImg addObject:img];
    }
    
    return defaultImg;
}

- (void)popImageForView: (UIImageView *)view {
    if ([stockImages count] == 0) {
        NSLog(@"No more images :(");
    }
    
    else {
        NSLog(@"MORE IMAGES!");
    
    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
        view.image = stockImages[0];
    
        [stockImages removeObjectAtIndex:0];
    }
    
}

- (void) randomizeMetricsForPhoto {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if ([countriesArray count] == 0) {
        [self constructCountries];
        numSwiped = 0;
    }
    
    NSNumber *randomLatitude = longitudeLatitude[numSwiped][0];
    NSNumber *randomLongitude = longitudeLatitude[numSwiped][1];
    
    CLLocationCoordinate2D coord = {.latitude =  [randomLatitude floatValue], .longitude = [randomLongitude floatValue]};
    MKCoordinateSpan span = {.latitudeDelta =  1, .longitudeDelta =  1};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];
    
    self.locationLabel.text = countriesArray[numSwiped];
    self.timeLabel.text = [NSString stringWithFormat:@"%i hour(s) ago", arc4random()%99 + 1];
    self.sharedNum.text = [NSString stringWithFormat:@"%i", arc4random()%999 + 1];
    self.citiesLabel.text = [NSString stringWithFormat:@"Cities: %i", arc4random()%99 + 1];
    self.milesLabel.text = [NSString stringWithFormat:@"Miles: %i", arc4random()%9999 + 1];
    self.countriesLabel.text = [NSString stringWithFormat:@"Countries: %i", arc4random()%9 + 1];
    
    for (int i = 0; i < 10; i++) {
        [self addRandom:self.randomButton];
    }
    
}

- (void) pushContentWithContentId: (NSString *)contentId toReceivers:(NSArray *)receivers withCaption:(NSString *)caption {
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:contentId, @"contentId", @"Increment", @"badge",  @"New great Tauss content!", @"alert", caption, @"caption", nil];
    PFPush *push = [PFPush new];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
}

- (void) checkForContentByUser: (NSString *)contentId {
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Content"];
    photoQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [photoQuery whereKey:@"createdBy" notEqualTo:contentId]; // - pushing to bryce
    //[photoQuery whereKey:@"submitter" equalTo:@"lea"]; // - pushing to lea
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Are we getting here at least...?");
        if (!error) {
            NSLog(@"LOG ALL THE OBJECTS %@", objects);
            if ([objects count] > 0) {
                NSLog(@"NO ERROR: Objects are - %@", objects);
                PFObject *imgObj = [objects lastObject];
                PFFile *imgFile = [imgObj objectForKey:@"file"];
                
                NSLog(@"IMG OBJ: %@", imgObj);
                
                PFImageView *imgView = [[PFImageView alloc] init];
                imgView.image = [UIImage imageNamed:@"errorImage"];
                imgView.file = imgFile;
                [imgView loadInBackground:^(UIImage *image, NSError *error) {
                    NSLog(@"IMG IS: %@", image);
                    if (image) {
                        [stockImages insertObject:image atIndex:0];
                        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                        [self viewsToSwipe];
                    }
                }];
            }
        }

        else {
            NSLog(@"We have failed...");
        }
    }];
}


@end
