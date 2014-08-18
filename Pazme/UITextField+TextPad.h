//
//  UITextField+textPad.h
//  Pazme
//
//  Created by Lea Marolt on 7/20/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (textPad)

- (CGRect)textRectForBounds:(CGRect)bounds;
- (CGRect)editingRectForBounds:(CGRect)bounds;

@end
