//
//  SearchEventInfoViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 21/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@interface SearchEventInfoViewController : UIViewController {
    
    IBOutlet UIButton   *joinButton;
    IBOutlet UILabel    *eventNameLabel;
}

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UIScrollView     *scrollView;
@property (strong, nonatomic) NSMutableDictionary              *thisEvent;
@property(strong,nonatomic)NSString *hostId;
@property(strong,nonatomic)NSString *eventId;
@property (strong, nonatomic) NSDictionary  *statistics;
@property(strong,nonatomic)NSDictionary *hostData;
@property (nonatomic) BOOL isPastEvent;
@property (nonatomic)         NSInteger                 eventIndex;

@end
