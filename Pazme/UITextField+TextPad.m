//
//  UITextField+textPad.m
//  Pazme
//
//  Created by Lea Marolt on 7/20/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

//
// To override UITextField Mehtods
//
// http://stackoverflow.com/questions/9424004/suppress-warning-category-is-implementing-a-method-which-will-also-be-implement/9622779#9622779
//
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

// Insert override

#import "UITextField+TextPad.h"

@implementation UITextField (textPad)

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 8,
                      bounds.size.width - 20, bounds.size.height - 16);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

// After the end of overriding add this
#pragma clang diagnostic pop

@end
