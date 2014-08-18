//
//  UILabel+BetterLabel.m
//  Pazme
//
//  Created by Lea Marolt on 8/9/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import "UILabel+BetterLabel.h"

@implementation UILabel (BetterLabel)

- (void) prettyLabel: (UILabel *) uglyLabel {
    [uglyLabel setFont:[UIFont fontWithName:@"ProximaNovaA-Light" size:25.0]];
}

@end
