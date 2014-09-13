//
//  UserProfileViewController.h
//  Pazme
//
//  Created by Lea Marolt on 8/16/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIView *userPhotoBgView;
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *miles;
@property (weak, nonatomic) IBOutlet UILabel *cities;
@property (weak, nonatomic) IBOutlet UILabel *countries;
@property (weak, nonatomic) IBOutlet UILabel *shared;

@end
