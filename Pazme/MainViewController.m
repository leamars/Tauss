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

@interface MainViewController () {
    int contentIndex;
    int dataLoader;
    NSMutableArray *contentData;
    int numSwiped;
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
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    
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
//    numSwiped = 0;
    
    contentData = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (int i = 1; i < 21; i++) {
        MDCSwipeToChooseView *view = [[MDCSwipeToChooseView alloc] initWithFrame:self.containerView.bounds  options:options];
        
        view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stock%i", i]];
        [contentData addObject:view];
        
        [self.containerView  addSubview:view];
    }
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
    
//    //contentIndex--;
//    NSLog(@"What is content index: %i", contentIndex);
//    
//    if (contentIndex == 0) {
//        for (int i = 0; i < 20; i++) {
//            [self loadDataIntoView];
//        }
//        [self viewWillAppear:YES];
//        contentIndex = 20;
//    }
}

#pragma mark - acquire content

- (NSArray *)getContentToSwipe {
    
    // acquire data
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    return data;
}

- (void) loadDataIntoView {
    // load data into view
    if (!([contentData count] == 0)){
            [self.containerView addSubview:contentData[0]];
            [contentData removeObjectAtIndex:0];
    }
    else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        label.text = @"No more content for you!!!";
        [self.view addSubview:label];
    }

}

@end
