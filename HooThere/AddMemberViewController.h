//
//  AddMemberViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 05/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"
@interface AddMemberViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong,nonatomic) NSMutableArray *listOfFriends;
@property (strong,nonatomic) NSMutableArray *listOfSelectedFriends;
@property (strong,nonatomic) NSMutableArray *alreadyMembersList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) XMPPRoom *room;
@property (strong,nonatomic) NSString *roomName;
-(void)getListofFriends;
- (IBAction)addToGroup:(id)sender;
- (IBAction)cancelAddingMembers:(id)sender;

@end
