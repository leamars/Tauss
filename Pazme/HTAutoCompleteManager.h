//
//  HTAutoCompleteManager.h
//  Pazme
//
//  Created by Lea Marolt on 7/10/14.
//  Copyright (c) 2014 Lea Marolt Sonnenschein. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "HTAutocompleteTextField.h"


typedef enum {
    HTAutocompleteTypeEmail, // Default
    HTAutocompleteTypeColor,
} HTAutocompleteType;


@interface HTAutocompleteManager : NSObject <HTAutocompleteDataSource>

+ (HTAutocompleteManager *)sharedManager;


@end
