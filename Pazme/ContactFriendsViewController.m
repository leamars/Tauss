//
//  ContactFriendsViewController.m
//  Pazme
//
//  Created by Lea Marolt on 6/23/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "ContactFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Parse/Parse.h>
#import "FriendCell.h"
#import "PazmeDataModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ContactFriendsViewController ()

@property (nonatomic, strong) NSArray *contactsOnPaz;
@property (nonatomic, strong) NSMutableArray *contactsNotOnPaz;
@property (nonatomic, strong) NSMutableArray *allEmailsArray;
@property (nonatomic, strong) NSMutableArray *allPhoneNumbersArray;

@end

@implementation ContactFriendsViewController {
    ABAddressBookRef _addressBook;
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
    
    self.contactsNotOnPaz = [NSMutableArray new];
    self.allEmailsArray = [NSMutableArray new];
    self.allPhoneNumbersArray = [NSMutableArray new];
    
    [self checkAddressBook];
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

- (void)checkAddressBook
{
    //Address book authorization.
    CFErrorRef error = NULL;
    switch (ABAddressBookGetAuthorizationStatus()){
            
        case kABAuthorizationStatusAuthorized: {
            _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            
            /* Do your work and once you are finished ... */
            [self useAddressBook:_addressBook];
            
            
            //Check this part out again.
            
            if (_addressBook != NULL){
                CFRelease(_addressBook);
            }
            break;
        }
            
        case kABAuthorizationStatusDenied:{
            //[self displayMessage:kDenied];
            NSLog(@"Denied");
            break;
        }
            
        case kABAuthorizationStatusNotDetermined:{
            _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            
            ABAddressBookRequestAccessWithCompletion
            (_addressBook, ^(bool granted, CFErrorRef error) {
                if (granted){
                    NSLog(@"Access was granted");
                    [self useAddressBook:_addressBook];
                } else{
                    NSLog(@"Access was not granted");
                }
                if (_addressBook != NULL){
                    CFRelease(_addressBook);
                }
            });
            break;
        }
            
        case kABAuthorizationStatusRestricted:{
            // [self displayMessage:kRestricted];
            NSLog(@"Restricted");
            break;
        }
    }
    
}

- (void)useAddressBook:(ABAddressBookRef)addressBook
{
    NSLog(@"addressBook: %@", addressBook);
    
    NSArray *arrayOfAllPeople = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSUInteger peopleCounter = 0;
    
    for (peopleCounter = 0; peopleCounter < [arrayOfAllPeople count];  peopleCounter++) {
        
        ABRecordRef thisPerson = (__bridge ABRecordRef) [arrayOfAllPeople objectAtIndex:peopleCounter];
        NSString *fullName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(thisPerson);
        
        /* Handle phone numbers */
        NSMutableArray *phones = [NSMutableArray new];
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
        NSUInteger phoneCount = ABMultiValueGetCount(phoneNumbers);
        if (phoneCount == 0) {
            //NSLog(@"No phone numbers");
        } else {
            for (NSUInteger pc = 0; pc < phoneCount; pc++) {
                /* And then get the phone number*/
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, pc);
                [phones addObject:phone];
                [self.allPhoneNumbersArray addObject:phone];
            }
        }
        
        /* Handle emails */
        NSMutableArray *emails = [NSMutableArray new];
        ABMultiValueRef emailsRef = ABRecordCopyValue(thisPerson, kABPersonEmailProperty);
        NSUInteger emailCount = ABMultiValueGetCount(emailsRef);
        
        if (emailCount == 0) {
            //NSLog(@"No emails for this contact");
        } else {
            for (NSUInteger ec = 0; ec < emailCount; ec++) {
                /* And then get the email address itself */
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailsRef, ec);
                [emails addObject:email];
                [self.allEmailsArray addObject:email];
            }
        }
        
        /* Handle Images */
        UIImage *image = [UIImage imageNamed:@"no_icon_light"];
        if (ABPersonHasImageData(thisPerson)) {
            CFDataRef imageData = ABPersonCopyImageData(thisPerson);
            image = [UIImage imageWithData:(__bridge  NSData *)imageData];
            CFRelease(imageData);
            // TODO (DrJid): Why can't i release this?
        }
        
        //We don't actually have to release these. CFRelease(nil) doesn't actually crash your program. Since we used bridge_transfer, we transferred ownership to ARC land. So ARC will free these up. However, as above for the image, we just used __bridge. WE didn't transfer ownership, so it's now OUR responsbility to free things up.
        //CFRelease(emails);
        //CFRelease(phoneNumbers);
        
        if (fullName && emails && phones && image) {
            NSDictionary *person = @{@"name": fullName,
                                     @"emails": emails,
                                     @"phones": phones,
                                     @"image": image };
            
            [self.contactsNotOnPaz addObject:person];
        }
    }
    [self checkforContactsOnPaz];
    
}

- (void)checkforContactsOnPaz
{
    NSMutableArray *userEmailsOnPaz = [NSMutableArray new];
    NSMutableArray *userPhonesOnPaz = [NSMutableArray new];
    
    PFQuery *emailQuery = [PFUser query];
    [emailQuery whereKey:@"email" containedIn:self.allEmailsArray];
    [emailQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    PFQuery *phoneQuery = [PFUser query];
    [phoneQuery whereKey:@"phone" containedIn:self.allPhoneNumbersArray];
    [phoneQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[emailQuery, phoneQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"bad bad errors: %@", [error localizedDescription]);
        } else {
            self.contactsOnPaz = objects;
            
            //We have a list of users who match some email address or phone in there.
            for (PFUser *user in objects) {
                
                if (user[@"email"]) {
                    [userEmailsOnPaz addObject:user[@"email"]];
                }
                
                if  (user[@"phone"]) {
                    [userPhonesOnPaz addObject:user[@"phone"]];
                }
            }
            
            //We can't mutate an array while enumerating so we make a copy of the contactsNotOnVoice
            NSArray *cnonv = [NSArray arrayWithArray:self.contactsNotOnPaz];
            
            for (NSDictionary *contact in cnonv) {
                
                for (NSString *email in contact[@"emails"]) {
                    
                    if ([userEmailsOnPaz containsObject:email]) {
                        //Remove from contactsNOTonVoice
                        [self.contactsNotOnPaz removeObject:contact];
                        break;
                    }
                }
                
                // This isn't really a problem because I just found out that that if you removeObject that is not in the array
                // Nothing happens. Whew. Thank you NSMutableArray.
                for (NSString *phone in contact[@"phones"]) {
                    if ([userPhonesOnPaz containsObject:phone]) {
                        [self.contactsNotOnPaz removeObject:contact];
                        break;
                    }
                }
            }
            
            //Sort the contacts out
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            [self.contactsNotOnPaz sortUsingDescriptors:@[sortDescriptor]];
            
            
            
            //Reload the tableview
            [self.contactsTableView reloadData];
        }
    }];
}

#pragma mark - tableView methods

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.frame.size.width, 18)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
    
    [view addSubview:label];
    view.backgroundColor = [UIColor blueColor];
    
    
    switch (section) {
        case 0: {
            label.text =  [NSString stringWithFormat:@"You have %ld contacts on Paz. Friend them!", self.contactsOnPaz.count];
            break;
        }
            
        case 1:
            label.text =   [NSString stringWithFormat:@"You can invite more contacts to join you!"];
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
            return self.contactsOnPaz.count;
            break;
            
        case 1: {
            return self.contactsNotOnPaz.count;
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
    
    UIImage *placeholderImage = [UIImage imageNamed:@"no_icon_light"];
    
    switch (indexPath.section) {
        case 0: {
            [cell.addFriendButton addTarget:self action:@selector(addFriendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            PFUser *user = self.contactsOnPaz[indexPath.row];
            cell.nameLabel.text = user[@"fullName"];
            
            
            //NSString *friendId = user[@"facebookId"];
            //NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200", friendId]];
            [cell.friendImageView setImageWithURL:user[@"profilePictureURL"] placeholderImage:placeholderImage];
            
            
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
            
            NSDictionary *contactDict = self.contactsNotOnPaz[indexPath.row];
            
            cell.friendImageView.image = contactDict[@"image"];
            
            cell.nameLabel.text = contactDict[@"name"];
            break;
        }
        default: {
            break;
        }
    }
    
    
    // NSDictionary *contact = self.allContacts[indexPath.row];
    // cell.textLabel.text = contact[@"name"];
    
    return cell;
}

- (void)addFriendButtonPressed:(id)sender
{
    FriendCell *cell = (FriendCell *)[[[sender superview] superview] superview];
    NSIndexPath *indexPath = [self.contactsTableView indexPathForCell:cell];
    
    PFUser *user =  self.contactsOnPaz[indexPath.row];
    
    //[self configureAddFriendButtonWithUser:user forCell:cell];
    
    NSLog(@"user: %@", user.username);
    
    
    PFRelation *friendsRelation = [[PFUser currentUser] relationforKey:@"friendsRelation"];
    
    if ([self isFriend:user]) {
        [cell.addFriendButton setImage:[UIImage imageNamed:@"purple_plus"] forState:UIControlStateNormal];
        
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
        [cell.addFriendButton setImage:[UIImage imageNamed:@"purple_checkmark"] forState:UIControlStateNormal];
        [[[PazmeDataModel sharedModel] myFriends] addObject:user];
        
        //If this user is a friend who has already added you , do NOT send a push.
        NSArray *pazzersWhoAddedMe = [[PazmeDataModel sharedModel] peopleWhoAddedMe];
        
        //Send a push that the user has been added by this particular friend.
        //Send the push notification.
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:user.objectId];
        
        //Find devices associated with these users.
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"owner" matchesQuery:userQuery];
        
        NSString *message;
        
        if (![self user:user containedInArray:pazzersWhoAddedMe]) {
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
    NSIndexPath *indexPath = [self.contactsTableView indexPathForCell:cell];
    
    NSDictionary *friendDict = self.contactsNotOnPaz[indexPath.row];
    
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:@"How would you like to reach out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    
    NSArray *phones = friendDict[@"phones"];
    NSArray *emails = friendDict[@"emails"];
    
    
    NSUInteger infoCount = phones.count + emails.count;
    
    /* if no contact info is present */
    if ( infoCount == 0 ) {
        //Nothing.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yikes!" message:@"Looks like there is no contact information here to send the invite :/" delegate:nil cancelButtonTitle:@"Dang.." otherButtonTitles:nil];
        [alert show];
    }
    
    /* if only 1 contact info is present */
    else if ( infoCount == 1 ) {
        //Only one of these is available. Which?
        if (phones.count == 1) {
            [self sendPhoneRequest:phones.firstObject];
            //show the screen to send a text to whatever phone number is available.
        } else if (emails.count == 1) {
            //Send to whatever email is available.
            [self sendEmailRequest:emails.firstObject];
        }
    }
    
    /* More than 1 contact info */
    else if ( infoCount > 1) {
        for (NSString *phone in phones) {
            [al addButtonWithTitle:phone];
        }
        
        for (NSString *email in emails) {
            [al addButtonWithTitle:email];
        }
        
        [al show];
    }
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


#pragma mark - MessageComposerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"result: %@", controller);
    [controller dismissViewControllerAnimated:YES completion:nil];
    if  (result == MessageComposeResultSent) {
        [PFAnalytics trackEvent:@"InvitationSentViaText"];
        NSLog(@"Sent text");
    }
    // Send the dimensions to Parse along with the 'search' event
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [PFAnalytics trackEvent:@"InvitationSentViaEmail"];
        
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Request

- (void)sendPhoneRequest:(NSString *)recipient
{
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.navigationBar.tintColor = [UIColor blueColor];
        controller.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
        
        
        controller.body = @"Hey! Join me on Paz! -insert appid when it's on store here-cxdxcds" ;
        controller.recipients = @[recipient];
        controller.messageComposeDelegate = self;
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void)sendEmailRequest:(NSString *)recipient
{
    if ([MFMailComposeViewController canSendMail] ) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.navigationBar.tintColor = [UIColor blueColor];
        controller.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor]};
        
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Hey! Join me on Paz!"];
        [controller setMessageBody:@"I've been using Paz since forever! -insert appstore id-" isHTML:NO];
        [controller setToRecipients:@[recipient]];
        if (controller)
            [self presentViewController:controller animated:YES completion:nil];
        
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!(buttonIndex == alertView.cancelButtonIndex)) {
        
        //Get the title.
        NSString *buttontitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        //If it's an email regex. Send email hehe
        if ([self isValidEmail:buttontitle]) {
            [self sendEmailRequest:buttontitle];
        } else {
            //Send phone
            [self sendPhoneRequest:buttontitle];
        }
    }
}



//Quick email regex. - http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios

-(BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction)toInterests:(id)sender {
    [self performSegueWithIdentifier:@"contactsToInterests" sender:self];
}
@end
