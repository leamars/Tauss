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

static CGFloat kDEFAULTCLUSTERSIZE = 0.5;
static NSString *const kTYPE1 = @"Banana";
static NSString *const kTYPE2 = @"Orange";

@interface MainViewController () <DBCameraViewControllerDelegate> {
    int contentIndex;
    int dataLoader;
    NSMutableArray *contentData;
    NSMutableArray *contentData2;
    int numSwiped;
    BOOL flipped;
    BOOL up;
    int pressNum;
    UIImage *imageToSend;
    OCAnnotation *clusterAnnotation;
}

@end

@implementation MainViewController

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
    
    [self configureECSlidingController];
    
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar";
//    [testObject saveInBackground];
    
    // You can customize MDCSwipeToChooseView using MDCSwipeToChooseViewOptions.
    
    // SWIPE VIEW PROGRAMATICALLY - [self.swipeToChooseView mdc_swipe:MDCSwipeDirectionLeft];
    
//    MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds options: options];
//    MDCSwipeToChooseView *view1 = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds  options: options];
//    MDCSwipeToChooseView *view2 = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds  options: options];
//    
//    view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock1"]];
//    view1.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock2"]];
//    view2.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock3"]];
//    
//    [self.containerView addSubview:view];
//    [self.containerView  addSubview:view1];
//    [self.containerView  addSubview:view2];
//    
//    contentIndex = 0;
//    dataLoader = 0;
//
    
    numSwiped = 1;
    
    contentData = [[NSMutableArray alloc] initWithCapacity:10];
    contentData2 = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self loadDataIntoView];
    flipped = NO;
    
    pressNum = 0;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    // MAP STUFF
    
    self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
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

- (void)configureECSlidingController {
    // setup swipe and button gestures for the sliding view controller
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    //    [[self.navigationController.viewControllers.firstObject view] addGestureRecognizer:self.slidingViewController.panGesture];
    
    // TO DO: Swipe to the right to reveal menu
}

#pragma mark - MDCSwipeToChooseDelegate Callbacks

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Couldn't decide, huh?");
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    numSwiped++;
    
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"Photo deleted!");
    } else {
        NSLog(@"Photo saved!");
    }
    
    [contentData removeObjectAtIndex:0];
    [contentData2 removeObjectAtIndex:0];
}

#pragma mark - acquire content

- (NSArray *)getContentToSwipe {
    
    // acquire data
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    return data;
}

- (void) loadDataIntoView {

//    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
//    options.delegate = self;
//    
//    for (int i = 0; i < 21; i++) {
//        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds options:options];
//        
//        view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i", i+1]];
//        [contentData addObject:view];
//    }
//    
//    for (int i = 0; i < 21; i++) {
//        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds options:options];
//        
//        view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i", i+1]];
//        [contentData2 addObject:view];
//
//    }
//    
//    [self.containerView addSubview:contentData[0]];
//    [contentData removeObjectAtIndex:0];
//    [contentData2 removeObjectAtIndex:0];
    

}

- (IBAction)flipImage:(id)sender {

//    if (!flipped) {
//        NSLog(@"NOT FLIPPED this view: %@ to this view: %@", contentData[numSwiped], contentData2[numSwiped]);
//    
//        [UIView transitionFromView:contentData[0]
//                            toView:contentData2[0]
//                          duration:1
//                           options:UIViewAnimationOptionTransitionFlipFromLeft
//                        completion:nil];
//        flipped = YES;
//    }
//    else {
//        NSLog(@"FLIPPED this view: %@ to this view: %@", contentData[numSwiped], contentData2[numSwiped]);
//        
//        [UIView transitionFromView:contentData2[0]
//                            toView:contentData[0]
//                          duration:1
//                           options:UIViewAnimationOptionTransitionFlipFromRight
//                        completion:nil];
//        flipped = NO;
//    }
    
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
            NSLog(@"WHAT IS THE NUMBER OF ANNOTATIONS IN THIS CLUSTER? %i", numOfPins);
            
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
            annotation.groupTag = kTYPE1;
        } else {
            annotation.groupTag = kTYPE2;
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
        longitude += ((arc4random()%max)/(CGFloat)max) * visibleRegion.span.longitudeDelta;
        latitude  -= ((arc4random()%max)/(CGFloat)max) * visibleRegion.span.latitudeDelta;
        
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



@end
