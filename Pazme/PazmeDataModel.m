//
//  PazmeDataModel.m
//  Pazme
//
//  Created by Lea Marolt on 7/7/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "PazmeDataModel.h"

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
    }
    return self;
}

@end
