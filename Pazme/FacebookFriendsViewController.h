//
//  FacebookFriendsViewController.h
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookFriendsViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *friends;
@property (weak, nonatomic) IBOutlet UITableView *fbContactsTableView;

@end
