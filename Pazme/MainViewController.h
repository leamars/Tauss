//
//  MainViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "OCMapView.h"
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareCount;
@property (weak, nonatomic) IBOutlet UIView *metricsView;
@property (weak, nonatomic) IBOutlet UILabel *sharedNum;
@property (weak, nonatomic) IBOutlet OCMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *locationIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numShared;
@property (weak, nonatomic) IBOutlet UIButton *timeIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *citiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *milesLabel;
@property (weak, nonatomic) IBOutlet UILabel *countriesLabel;

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *frontImage;
@property (nonatomic, strong) UIImage *currentImage;

- (IBAction)addRandom:(id)sender;


- (IBAction)takePhoto:(id)sender;
- (IBAction)showMetricsView:(id)sender;


@end


