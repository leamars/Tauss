//
//  PazmeDataModel.m
//  Pazme
//
//  Created by Lea Marolt on 7/7/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "PazmeDataModel.h"
#import <Parse/Parse.h>

@implementation PazmeDataModel

+(PazmeDataModel *) sharedModel {
    static PazmeDataModel *_sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[PazmeDataModel alloc] init];
    });
    
    return _sharedModel;
}

- (id) init {
    self = [super init];
    if (self) {
        self.myFriends = [[NSMutableArray alloc] init];
        self.peopleWhoAddedMe = [[NSMutableArray alloc] init];
        self.userPhotos = [[NSMutableArray alloc] init];
    }
    
    [self getUserPhotos];
    
    return self;
}

- (void) getUserPhotos {
    [self grabImagesFromParse];
    
}

- (void) grabImagesFromParse {
    
    self.allContentImages = [NSMutableArray new];
    
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Content"];
    [photoQuery includeKey:@"createdBy"];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"ERROR: There was an error with the Query for Content!");
        } else {
            [self.allContentImages addObjectsFromArray:objects];
            [self makeImagesArray];
        }
    }];
    
}

- (void) makeImagesArray {
    
    self.imagesArray = [NSMutableArray new];
    
    for (PFObject *photo in self.allContentImages) {
        PFUser *photoUser = [photo objectForKey:@"createdBy"];
        if ([[photoUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [self.imagesArray addObject:photo];
        }
    }
}

@end
