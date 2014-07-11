//
//  DZNPhotoDisplayController.h
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import <FlickrKit/FlickrKit.h>
#import <PXAPI.h>

@class DZNPhotoPickerController;

/*
 * The collection view controller in charge of displaying the resulting thumb images.
 */
@interface DZNPhotoDisplayViewController : UICollectionViewController

/* The nearest ancestor in the view controller hierarchy that is a photo picker controller. */
@property (nonatomic, readonly) DZNPhotoPickerController *navigationController;
/* The searching string. If setted before presentation, the controller will automatically start searching. */
@property (nonatomic, strong) NSString *searchTerm;
/* The count number of columns of thumbs to be displayed. */
@property (nonatomic) NSUInteger columnCount;
/* The count number of rows of thumbs to be diplayed. */
@property (nonatomic) NSUInteger rowCount;
/* YES if the controller started a request and loading content. */
@property (nonatomic, getter = isLoading) BOOL loading;

@end
