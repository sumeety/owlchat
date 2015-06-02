//
//  ImageDetailsViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 23/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@interface ImageDetailsViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    IBOutlet UILabel            *nameLabel;
    IBOutlet UILabel            *dateLabel;
    IBOutlet UIImageView        *uploaderImageView;
}

@property (strong, nonatomic) IBOutlet UIScrollView     *imagesScrollview;
@property (nonatomic, strong) NSMutableArray            *listOfImages;
@property (nonatomic)         NSInteger                 imageIndex;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) NSMutableDictionary       *thisEvent;
@property (strong, nonatomic) UIImageView               *currentImageView;
@property (nonatomic, strong) UIActionSheet             *actionSheet;
@property (nonatomic)         BOOL                      isEventSaved;
@property (nonatomic)         NSInteger                 eventIndex;

@end
