//
//  UserListViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 27/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong,nonatomic) NSMutableArray *listOfFriends;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
-(void)getListofFriends;
@end
