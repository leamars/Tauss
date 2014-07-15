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

@interface MainViewController () {
    int contentIndex;
    int dataLoader;
    NSMutableArray *contentData;
    NSMutableArray *contentData2;
    int numSwiped;
    BOOL flipped;
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
    [self.containerView addSubview:contentData[0]];
}

#pragma mark - acquire content

- (NSArray *)getContentToSwipe {
    
    // acquire data
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    return data;
}

- (void) loadDataIntoView {

    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    
    for (int i = 0; i < 21; i++) {
        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds options:options];
        
        view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i", i+1]];
        [contentData addObject:view];
    }
    
    for (int i = 0; i < 21; i++) {
        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds options:options];
        
        view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i", i+1]];
        [contentData2 addObject:view];

    }
    
    [self.containerView addSubview:contentData[0]];
    [contentData removeObjectAtIndex:0];
    [contentData2 removeObjectAtIndex:0];
    

}

- (IBAction)flipImage:(id)sender {

    if (!flipped) {
        NSLog(@"NOT FLIPPED this view: %@ to this view: %@", contentData[numSwiped], contentData2[numSwiped]);
    
        [UIView transitionFromView:contentData[0]
                            toView:contentData2[0]
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:nil];
        flipped = YES;
    }
    else {
        NSLog(@"FLIPPED this view: %@ to this view: %@", contentData[numSwiped], contentData2[numSwiped]);
        
        [UIView transitionFromView:contentData2[0]
                            toView:contentData[0]
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        completion:nil];
        flipped = NO;
    }
    
}
@end
