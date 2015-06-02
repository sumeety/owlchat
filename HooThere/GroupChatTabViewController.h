//
//  GroupChatTabViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 04/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
@interface GroupChatTabViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *chatRoomListTableView;
-(void)loadPeerToPeerChatUser;
@property (strong, nonatomic) IBOutlet GADBannerView *adMobBannerView;
@end
