//
//  Interests.m
//  Pazme
//
//  Created by Lea Marolt on 7/4/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "Interests.h"

@implementation Interests

+ (Interests *)sharedInterests {
    static dispatch_once_t token;
    static Interests *_sharedInterests = nil;
    
    dispatch_once(&token, ^ {
        // YAY, now I don't have to call it ever!!! Thanks DrJid.
        _sharedInterests = [[Interests alloc] init];
            NSLog(@"Currently in shared interests: %@", _sharedInterests);
        [_sharedInterests interestsWithData];
    });
    return _sharedInterests;
}

- (void) interestsWithData {
    
    NSArray *interestImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"read"], [UIImage imageNamed:@"shopping"], [UIImage imageNamed:@"drink"], [UIImage imageNamed:@"music"], [UIImage imageNamed:@"travel"], [UIImage imageNamed:@"sports"], [UIImage imageNamed:@"crafts"], [UIImage imageNamed:@"exercise"], nil];

    
    NSArray *interestNames =  @[@"Reading", @"Shopping", @"Cocktails", @"Music", @"Traveling", @"Sports", @"Crafts", @"Exercise"];
    
    
    _interests = [[NSMutableArray alloc] initWithCapacity:7];
    
    for (int i = 0; i < [interestNames count]; i++) {
        
        Interest *interest = [[Interest alloc]interestWithImage:interestImages[i] andTag:interestNames[i]];        
        [_interests addObject:interest];
    }
}

@end

