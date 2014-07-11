//
//  FacebookFriendsViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "FacebookFriendsViewController.h"
#import <Parse/Parse.h>
#import "PazmeDataModel.h"
#import "FriendCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FacebookFriendsViewController ()

@property (nonatomic, strong) PFUser *currentUser;

@property (nonatomic, strong) NSArray *facebookFriendsOnPaz;
@property (nonatomic, strong) NSMutableArray *facebookFriendsNotOnPaz;

@end

@implementation FacebookFriendsViewController

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
    
    NSLog(@"friends: %@", [[PazmeDataModel sharedModel] myFriends] );
    self.friends = [[PazmeDataModel sharedModel] myFriends] ;
    
    self.currentUser =  [PFUser currentUser];
    [self checkForFBFriendsOnPaz];
    //NSLog(@"self.friends: %@", self.friends);
    
    [self requestMe];
    [self requestFriends];
    [self getFriendList];
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

- (void)checkForFBFriendsOnPaz
{
    NSArray *fbFriends = self.currentUser[@"facebookFriends"];
    //NSLog(@"fbf: %@", fbFriends);
    NSMutableArray *fbFriendsIDArray = [NSMutableArray arrayWithArray:fbFriends];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"facebookId" containedIn:fbFriendsIDArray];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //NSLog(@"fb friends: %@", objects);
        self.facebookFriendsOnPaz = objects;
        NSMutableArray *fbIdsFriendsUsingPaz = [NSMutableArray new];
        
        for ( PFUser *friend in objects) {
            [fbIdsFriendsUsingPaz addObject:friend[@"facebookId"]];
        }
        
        //NSArray *fbFriendsUsingPaz = objects;
        NSLog(@"facebook friends on paz: %@", self.facebookFriendsOnPaz);
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {
                NSLog(@"Really hate errors: %@", [error localizedDescription]);
            } else {
                //NSLog(@"result: %@", result);
                NSArray *data = result[@"data"];
                
                NSLog(@"What is in this data: %@", data);
                
                /*
                 NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
                 for (NSDictionary *friendData in data) {
                 [facebookIds addObject:friendData[@"id"]];
                 }
                 */
                
                self.facebookFriendsNotOnPaz = [[NSMutableArray alloc] initWithArray:data];
                
                //Loop through array of dicts.
                for (NSDictionary *friendDict in data) {
                    
                    //If this friend is also on paz
                    if ([fbIdsFriendsUsingPaz containsObject:friendDict[@"id"]]) {
                        //Remove from fbFriendsNOTonPaz.
                        [self.facebookFriendsNotOnPaz removeObject:friendDict];
                    }
                }
                
                //Sort all these dictionaries.
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                [self.facebookFriendsNotOnPaz sortUsingDescriptors:@[sortDescriptor]];
                
                
                [self.fbContactsTableView reloadData];
                //NSLog(@"fbFriendsNOTonPaz: %@", self.facebookFriendsNOTonPaz);
            }
        }];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    view.layer.cornerRadius = 1.0f;
    view.layer.masksToBounds = YES;
    
    /*
     view.layer.shadowColor = [UIColor grayColor].CGColor;
     view.layer.shadowOpacity = 7;
     view.layer.shadowRadius = 17.0f;
     view.layer.masksToBounds = NO;
     
     UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
     view.layer.shadowPath = path.CGPath;
     */
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.frame.size.width , 18)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    
    [view addSubview:label];
    view.backgroundColor = [UIColor redColor];
    
    
    switch (section) {
        case 0: {
            label.text = [NSString stringWithFormat:@"You have %ld facebook friends on Voyse!", (unsigned long)self.facebookFriendsOnPaz.count];
            break;
        }
            
        case 1:
            label.text =  [NSString stringWithFormat:@"You can invite more friends to join you!"];
            break;
            
        default:
            label.text = @"Facebook friends";
            break;
    }
    
    
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return self.facebookFriendsOnPaz.count;
            break;
            
        case 1: {
            return self.facebookFriendsNotOnPaz.count;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //Customize Cell
    
    //Remove all the targets from the cell's button
    [cell.addFriendButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"drink"];
    
    switch (indexPath.section) {
        case 0: {
            [cell.addFriendButton addTarget:self action:@selector(addFriendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            PFUser *user = self.facebookFriendsOnPaz[indexPath.row];
            cell.nameLabel.text = user[@"fullName"];
            
            NSString *friendId = user[@"facebookId"];
            NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200", friendId]];
            
            [cell.friendImageView setImageWithURL:profilePictureURL
                               placeholderImage:placeholderImage
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                          if (image && cacheType == SDImageCacheTypeNone)
                                          {
                                              cell.friendImageView.alpha = 0.0;
                                              [UIView animateWithDuration:2.0
                                                               animations:^{
                                                                   cell.friendImageView.alpha = 1.0;
                                                               }];
                                          }
                                      }];
            
            
            if ([self isFriend:user]) {
                [cell.addFriendButton setImage:[UIImage imageNamed:@"purple_checkmark"] forState:UIControlStateNormal];
            } else {
                [cell.addFriendButton setImage:[UIImage imageNamed:@"purple_plus"] forState:UIControlStateNormal];
            }
        }
            break;
            
        case 1: {
            [cell.addFriendButton addTarget:self action:@selector(inviteFriendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.addFriendButton setImage:[UIImage imageNamed:@"purple_plus"] forState:UIControlStateNormal];
            
            NSDictionary *friendDict = self.facebookFriendsNotOnPaz[indexPath.row];
            NSString *friendId = friendDict[@"id"];
            NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200", friendId]];
            
            
            [cell.friendImageView setImageWithURL:profilePictureURL
                               placeholderImage:nil
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                          if (image && cacheType == SDImageCacheTypeNone)
                                          {
                                              cell.friendImageView.alpha = 0.0;
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   cell.friendImageView.alpha = 1.0;
                                                               }];
                                          }
                                      }];
            
            
            
            
            // NSLog(@"friendDcit: %@", friendDict);
            cell.nameLabel.text = friendDict[@"name"];
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)addFriendButtonPressed:(id)sender
{
    FriendCell *cell = (FriendCell *)[[[sender superview] superview] superview];
    NSIndexPath *indexPath = [self.fbContactsTableView indexPathForCell:cell];
    
    PFUser *user =  self.facebookFriendsOnPaz[indexPath.row];
    
    //[self configureAddFriendButtonWithUser:user forCell:cell];
    
    NSLog(@"user: %@", user.username);
    
    
    PFRelation *friendsRelation = [[PFUser currentUser] relationforKey:@"friendsRelation"];
    
    if ([self isFriend:user]) {
        [cell.addFriendButton setImage:[UIImage imageNamed:@"drink"] forState:UIControlStateNormal];
        
        for (PFUser *friend in [[PazmeDataModel sharedModel] myFriends]) {
            if ([friend.objectId isEqualToString:user.objectId]) {
                [[[PazmeDataModel sharedModel] myFriends] removeObject:friend];
                break;
            }
        }
        NSLog(@"Removing friend: %@", user.username);
        [friendsRelation removeObject:user];
    } else {
        NSLog(@"Will add friend: %@", user.username);
        [friendsRelation addObject:user];
        [cell.addFriendButton setImage:[UIImage imageNamed:@"sports"] forState:UIControlStateNormal];
        [[[PazmeDataModel sharedModel] myFriends] addObject:user];
        
        //If this user is a friend who has already added you , do NOT send a push.
        NSArray *voysersWhoAddedMe = [[PazmeDataModel sharedModel] peopleWhoAddedMe];
        
        //Send a push that the user has been added by this particular friend.
        //Send the push notification.
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:user.objectId];
        
        //Find devices associated with these users.
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"owner" matchesQuery:userQuery];
        
        NSString *message;
        
        if (![self user:user containedInArray:voysersWhoAddedMe]) {
            //            NSLog(@"They are not friends who have added you!");
            
            message = [NSString stringWithFormat:@"%@ added you as a friend. Add %@ back!", [[PFUser currentUser] username], [[PFUser currentUser] username]];
            
        } else {
            //            NSLog(@"This user already added you. Push not neccessarily.");
            
            message = [NSString stringWithFormat:@"%@ added you back!", [[PFUser currentUser] username] ];
            
        }
        NSLog(@"push notification message: %@", message);
        
        NSDictionary *data = @{@"sound": @"Sound.caf",
                               @"alert": message,
                               };
        
        //Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
    }
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete adding friend.." message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"Helll yeah!!!");
        }
    }];
}


- (void)inviteFriendButtonPressed:(id)sender
{
    FriendCell *cell = (FriendCell *)[[[sender superview] superview] superview];
    NSIndexPath *indexPath = [self.fbContactsTableView indexPathForCell:cell];
    
    NSDictionary *friendDict = self.facebookFriendsNotOnPaz[indexPath.row];
    NSString *friendId = friendDict[@"id"];
    
    NSDictionary *params = @{@"to": friendId };
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"I am loving Voyse!!"
                                                    title:@"Smashing!"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          //NSLog(@"REsultULR: %@", resultURL);
                                                          // Case A: Error launching the dialog or sending request.
                                                          //NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}
                                              friendCache:nil
     ];
}


#pragma mark - Helper Methods.

- (BOOL)isFriend:(PFUser *)user {
    for(PFUser *friend in [[PazmeDataModel sharedModel] myFriends]) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)user:(PFUser *)user containedInArray:(NSArray *)pfuserArray {
    for (PFUser *pfuser in pfuserArray) {
        if ([user.objectId isEqualToString:pfuser.objectId]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - fb tests 

- (void)requestMe {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                           NSDictionary<FBGraphUser> *me,
                                                           NSError *error) {
        if(error) {
            NSLog(@"error!! %@", error);
            return;
        }
        
        NSLog(@"My name is %@", me.name);
    }];
}

-(void)requestFriends {
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id data, NSError *error) {
        if(error) {
            NSLog(@"error!! %@", error);
            return;
        }
        
        NSArray* friends = (NSArray*)[data data];
        NSLog(@"You have %d friends", [friends count]);
    }];
}

-(void)getFriendList   {
    NSArray *array = [NSArray arrayWithObjects:@"user_friends", nil];
    
    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me?fields=friends.fields(first_name,last_name)" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSDictionary* friendsDic = [result objectForKey:@"friends"];
        NSArray *friends = [friendsDic objectForKey:@"data"];
        for (NSDictionary *friend in friends) {
            NSLog(@"firstname %@",friend[@"first_name"]);
            NSLog(@"last name %@",friend[@"last_name"]);
        }
    }];
}

- (IBAction)doneWithSignUp:(id)sender {
    [self performSegueWithIdentifier:@"fbToInterests" sender:self];
}
@end
