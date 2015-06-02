//
//  HootHereViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>
#import "AddressBook.h"
@import GoogleMobileAds;
@interface HootHereViewController : UIViewController <FBFriendPickerDelegate, UIScrollViewDelegate, FBLoginViewDelegate, UISearchBarDelegate> {
    
    IBOutlet UIView         *tabLineView;
    IBOutlet UITableView    *hootHereTableView;
    FBLoginView                 *loginview;
    IBOutlet UIImageView    *textFieldBackground;
    IBOutlet UIButton       *hooThereButton;
    IBOutlet UIButton       *facebookButton;
    IBOutlet UIButton       *contactsButton;
    IBOutlet UISearchBar *searchBarField;
    
    IBOutlet UILabel *searchLabel;
    IBOutlet UIImageView *aloneImage;
    IBOutlet UILabel *aloneLabel;
}
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (nonatomic, strong) NSMutableArray    *listOfFriends;
@property (nonatomic, strong) NSMutableArray    *listOfFacebookFriends;
@property (nonatomic, strong) NSMutableArray    *listOfHootHereFriends;
@property (nonatomic, strong) NSMutableArray    *searchArray;
@property (nonatomic, strong) NSMutableArray    *listOfFacebookInvites;
@property (nonatomic, strong) NSMutableArray    *listOfFriendsSelected;
@property (nonatomic,strong) NSMutableArray     *statusFFriends;
//@property (nonatomic,strong) NSMutableArray     *usersInChat;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, strong) NSString          *listType;
@property (nonatomic) BOOL                      facebookSelected;
@property (nonatomic) NSInteger fromWhereCalled;
@property (nonatomic) BOOL                      searching;
@property (nonatomic,strong) NSString           *acceptToId  ;
@property (nonatomic)         BOOL      facebookInformationLoaded;
@property (nonatomic)         BOOL      isAuthenticatedUser;

@property(nonatomic,strong)NSString *rejectToId;
- (IBAction)tabButtonClicked:(UIButton *)button;
- (IBAction)hooThereButtonClicked:(id)sender;
- (IBAction)facebookButtonClicked:(id)sender;
- (IBAction)contactsButtonClicked:(id)sender;
- (IBAction)hootAFriendButtonClicked:(UIButton *)hootAFriendButton;
- (void)loadUserInChat;
@property (nonatomic,strong)NSString * fromWhereItCalled;
@property (strong, nonatomic) IBOutlet GADBannerView *adMobBannerView;

@end
