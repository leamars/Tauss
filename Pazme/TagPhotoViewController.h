//
//  TagPhotoViewController.h
//  Pazme
//
//  Created by Lea Marolt on 8/17/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DWTagList.h"

@interface TagPhotoViewController : UIViewController <CLLocationManagerDelegate, DWTagListDelegate> {
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (nonatomic, strong) UIImage *receivedImage;
@property (nonatomic, strong) DWTagList *tagList;
@property (weak, nonatomic) IBOutlet UITextField *tagField;
@property (weak, nonatomic) IBOutlet UIView *backgroundTagView;
@property (nonatomic, strong) DWTagList *photoTags;

@property (weak, nonatomic) IBOutlet UIView *broadcast;
- (IBAction)broadcastImage:(id)sender;

@end
