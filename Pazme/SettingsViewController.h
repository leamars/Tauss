//
//  SettingsViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UILabel *broadcastCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *acknCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactCellLabel;
@property (weak, nonatomic) IBOutlet UISwitch *broadcastSwitch;

- (IBAction)switchChanged:(id)sender;

@end
