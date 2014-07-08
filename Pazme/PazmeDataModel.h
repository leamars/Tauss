//
//  PazmeDataModel.h
//  Pazme
//
//  Created by Lea Marolt on 7/7/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PazmeDataModel : NSObject

@property (nonatomic, strong) NSMutableArray *myFriends;
@property (nonatomic, strong) NSMutableArray *peopleWhoAddedMe;

+ (PazmeDataModel *) sharedModel;

@end
