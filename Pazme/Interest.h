//
//  Interest.h
//  Pazme
//
//  Created by Lea Marolt on 7/4/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Interest : NSObject

@property(nonatomic,strong) UIImage *image;

// Lookup info
@property(nonatomic,strong) NSString *tag;
@property (nonatomic, strong) NSNumber *numOfSelected;

- (id)interestWithImage:(UIImage *)image andTag:(NSString *)tag;

@end
