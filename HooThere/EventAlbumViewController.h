//
//  EventAlbumViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 20/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@interface EventAlbumViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    UIImagePickerController     *pickerController;
    IBOutlet UICollectionView   *eventAlbumView;
}

@property (nonatomic, strong) NSMutableArray            *listOfImages;
@property (nonatomic)         BOOL                      canUpload;
@property (strong, nonatomic) NSMutableDictionary       *thisEvent;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic)         BOOL                      isEventSaved;
@property (nonatomic)         NSInteger                 eventIndex;
@property BOOL canLoad;

@end
