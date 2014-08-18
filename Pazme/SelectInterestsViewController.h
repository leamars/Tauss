//
//  SelectInterestsViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectInterestsViewController : UIViewController

// Outlets
@property (weak, nonatomic) IBOutlet UICollectionView *interestsCollection;
@property (weak, nonatomic) IBOutlet UIButton *toMainButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

// Actions
- (IBAction)toMainScreen:(id)sender;

@end
