//
//  Interests.h
//  Pazme
//
//  Created by Lea Marolt on 7/4/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Interest.h"

@interface Interests : NSObject

@property (nonatomic, strong) NSMutableArray *interests;

+ (Interests *) sharedInterests;
-(void) interestsWithData;

@end
