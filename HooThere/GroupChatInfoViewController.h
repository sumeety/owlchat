//
//  GroupChatInfoViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 02/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"
@interface GroupChatInfoViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSString *eventName;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic)XMPPRoom *room;
@end
