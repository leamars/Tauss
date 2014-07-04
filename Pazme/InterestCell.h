//
//  InterestCell.h
//  Pazme
//
//  Created by Lea Marolt on 7/4/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class Interest;

@interface InterestCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UIImageView *interestImage;
@property (weak, nonatomic) IBOutlet UILabel *interestLabel;
@property(nonatomic, strong) Interest *interest;

@end
