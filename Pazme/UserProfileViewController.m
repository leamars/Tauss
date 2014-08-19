//
//  UserProfileViewController.m
//  Pazme
//
//  Created by Lea Marolt on 8/16/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "UserProfileViewController.h"
#import <Parse/Parse.h>
#import "PhotoCell.h"

@interface UserProfileViewController () {
    PFUser *currrentUser;
    NSMutableArray *allContent;
    NSMutableArray *imagesArray;
}

@end

@implementation UserProfileViewController

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
    
    //currrentUser = [PFUser currentUser];
    
    [self.miles setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:20.0]];
    [self.cities setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:20.0]];
    [self.countries setFont:[UIFont fontWithName:@"ProximaNovaA-Lixght" size:20.0]];
    [self.shared setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:24.0]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    NSString *profilePictureString = [[PFUser currentUser] objectForKey:@"profilePicURL"];
    NSLog(@"What is the URL: %@", profilePictureString);
    NSURL *url = [NSURL URLWithString:profilePictureString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *profileImage = [UIImage imageWithData:data];
    
    NSLog(@"Profile Image: %@", profileImage);
    
    if (profileImage) {
        
        [self.userPhotoImageView setImage:profileImage];
        [self resizeImage:self.userPhotoImageView.image toWidth:180 andHeight:180];
        
    }
    else {
        //        UIView *noProfilePicture = [UIView new];
        //        [noProfilePicture view];
        //        [self.profilePictureImageView addSubview:[UIImage imageNamed:@"camera"]];
    }
    
    self.userPhotoImageView.layer.cornerRadius = 50;
    self.userPhotoImageView.layer.masksToBounds = YES;
    
    self.userPhotoBgView.layer.cornerRadius = 58;
    self.userPhotoBgView.layer.masksToBounds = YES;
    
    [self resizeImage:self.userPhotoImageView.image toWidth:200 andHeight:200];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    currrentUser = [PFUser currentUser];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self grabImagesFromParse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) grabImagesFromParse {
    
    allContent = [[NSMutableArray alloc] initWithCapacity:20];
    NSLog(@"My user is: %@", [currrentUser objectId]);
    
    
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Content"];
    [photoQuery whereKey:@"createdBy" equalTo:[currrentUser objectId]];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Getting to the query??");
        if (error) {
            NSLog(@"ERROR: There was an error with the Query for Content!");
        } else {
            [allContent addObjectsFromArray:objects];
            if ([allContent count] > 0) {
                [self.photoCollectionView reloadData];
            }
        }
    }];
    
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

#pragma mark - Helper Methods

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

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    if ([allContent count] > 0) {
        NSLog(@"What is the count? %i", [allContent count]);
        return [allContent count];
    }
    else {
        return 0;
    }
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    PFObject *photoFile;
    
    if ([allContent count] > 0) {
        photoFile = allContent[indexPath.row];
    }
    
    PFImageView *currentPhoto = [[PFImageView alloc] init];
    
    if (photoFile) {
        currentPhoto.file = [photoFile objectForKey:@"file"];
        [currentPhoto loadInBackground];
    }
    else {
        currentPhoto.image = [UIImage imageNamed:@"defaultImage"]; // placeholder image
    }
    
    cell.photo.image = [self resizeImage:currentPhoto.image toWidth:70.0 andHeight:70.0];
    cell.parseId = [photoFile objectId];

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
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(70, 70);
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


@end
