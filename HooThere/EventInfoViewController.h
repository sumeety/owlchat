//
//  EventInfoViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 20/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@interface EventInfoViewController : UIViewController {
    
    IBOutlet UIButton   *acceptButton;
    IBOutlet UIButton   *inviteFriendsButton;
    IBOutlet UILabel    *eventNameLabel;
}

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UIScrollView     *scrollView;
@property (strong, nonatomic) Events                    *thisEvent;
@property(strong,nonatomic)NSString *hostId;
@property (strong, nonatomic) NSDictionary  *statistics;
@property(strong,nonatomic)NSDictionary *hostData;
@property BOOL canLoad;

@end
