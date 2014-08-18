//
//  SelectInterestsViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "SelectInterestsViewController.h"
#import "Interest.h"
#import "InterestCell.h"
#import "Interests.h"
#import <Parse/Parse.h>

@interface SelectInterestsViewController ()

@end

@implementation SelectInterestsViewController {
    NSMutableArray *interestsArray;
    PFUser *user;
    NSMutableArray *userTags;
}

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
    
    interestsArray = [[NSMutableArray alloc] init];
    interestsArray = [[Interests sharedInterests] interests];
    
    user = [PFUser currentUser];
    
    userTags = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (user[@"tags"]) {
        userTags = [NSMutableArray arrayWithArray:user[@"tags"]];
    }
    else {
        userTags = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    [self.topLabel setFont:[UIFont fontWithName:@"Lobster1.4" size:30.0]];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
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

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [interestsArray count];
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    InterestCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"InterestCell" forIndexPath:indexPath];
    
    Interest *currentInterest = interestsArray[indexPath.row];
    
    // check if the interest has been selected - if yes, don't change bg color, if no, change bg color
    // also check if usertags has something in it already
    if (![interestsArray[indexPath.row] selected] || [userTags count] > 0) {
        
        //check if the tag of the cell matches any of the tags previously selected by the user
        //and mark the interest object appropriately
        if ([userTags containsObject:currentInterest.tag]) {
            cell.backgroundColor = [UIColor redColor];
            currentInterest.selected = YES;
        }
        else {
            cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        }
    }
    else {
        cell.backgroundColor = [UIColor redColor];
    }
    
    cell.interestImage.image = currentInterest.image;
    [cell.interestLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:15.0]];
    cell.interestLabel.text = currentInterest.tag;
    return cell;
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    InterestCell *cell = (InterestCell *)[collectionView cellForItemAtIndexPath:indexPath];
    Interest *currentInterest = interestsArray[indexPath.row];
    
    if (![currentInterest selected]) {
        
        [interestsArray[indexPath.row] setSelected:YES];
        // Animate cell background color to re
        [UIView animateWithDuration:0.5 animations:^{
            cell.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:125.0/255.0 blue:117.0/255.0 alpha:0.6];
        }];
        
        // Set tags for the user
        [userTags addObject:currentInterest.tag];
        user[@"tags"] = userTags;
    }
    else {
        [currentInterest setSelected:NO];
        // Animate cell background color to normal
        [UIView animateWithDuration:0.5 animations:^{
            cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        }];
        
        [userTags removeObject:currentInterest.tag];
    }
    
    cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        // animate it to the identity transform (100% scale)
        cell.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
    
    // TO DO: Move the saving of the user to some other function, so we don't do it OVER and OVER again.
    user[@"tags"] = userTags;
    [user saveInBackground];
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    

}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize retval = CGSizeMake(125, 125);
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 25, 50, 25);
}

- (IBAction)toMainScreen:(id)sender {
    [user saveInBackground];
    [self showMainScreen];
}

- (void)showMainScreen
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *slideViewController = [mainStoryboard instantiateInitialViewController];
    [self presentViewController:slideViewController animated:NO completion:nil];
}

@end
