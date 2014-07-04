//
//  InterestCell.m
//  Pazme
//
//  Created by Lea Marolt on 7/4/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "InterestCell.h"
#import "Interest.h"

@implementation InterestCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setInterest:(Interest *)interest
{
    if(_interest != interest)
    {
        _interest = interest;
    }
    
    self.imageView.image = _interest.image;
}

@end
