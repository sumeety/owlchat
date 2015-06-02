//
//  EventDetailsViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 10/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"
#import "SeeAllViewController.h"
#import "InviteFriendsViewController.h"

@interface EventDetailsViewController : UIViewController {
    
    IBOutlet UIView     *detailInfoView;
    IBOutlet UIView   *albumView;

    
    IBOutlet UIButton *acceptButton;
    IBOutlet UIButton *inviteFriendsButton;
    IBOutlet UIImageView *eventBannerImageView;
   
    IBOutlet UIButton *orgainserNameButton;
    IBOutlet UIImageView *hostImageView;
    IBOutlet UILabel *hostNameLabel;
    IBOutlet UILabel *locationNameLabel;
    IBOutlet UILabel *eventStartDateLabel;
    IBOutlet UILabel *lblHooCame;
    IBOutlet UILabel *lblInvited;
    IBOutlet UILabel *lblGoingThere;
    IBOutlet UILabel *lblHooThere;
    IBOutlet UIImageView *detailsInfoIcon;
    IBOutlet UIImageView *albumIcon;
}
- (IBAction)organiserNameClicked:(id)sender;

- (IBAction)acceptButtonClicked:(id)sender;

- (IBAction)detailInfoButtonClicked:(id)sender;

- (IBAction)albumButtonClicked:(id)sender;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) Events    *thisEvent;
@property (strong, nonatomic) NSString  *eventId;
@property (nonatomic) BOOL fromNotification;
@property (strong, nonatomic) NSString  *hostName;
@property (strong, nonatomic) NSString  *eventStatus;
@property(strong,nonatomic)NSString *hostId;
@property(strong,nonatomic)NSDictionary *hostData;
@property (strong, nonatomic) NSDictionary  *statistics;
@property(strong ,nonatomic)NSMutableArray *imageViewArray;
@property (strong,nonatomic)NSMutableArray *hooThereFriends;
@property (strong,nonatomic)NSMutableArray *invitedFriends;
@property (strong,nonatomic)NSMutableArray *acceptedFriends;
@property (strong,nonatomic)UILabel *goingStatsLabel;
@property BOOL removePreviousView;

@end
