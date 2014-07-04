//
//  Interest.m
//  Pazme
//
//  Created by Lea Marolt on 7/4/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "Interest.h"

@implementation Interest

-(id) interestWithImage:(UIImage *)image andTag:(NSString *)tag {
    Interest *interest = [[Interest alloc] init];
    
    [interest setImage:image];
    [interest setTag:tag];
    
    return interest;
}

@end
