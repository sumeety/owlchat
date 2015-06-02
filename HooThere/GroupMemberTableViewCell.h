//
//  GroupMemberTableViewCell.h
//  Hoothere
//
//  Created by UnoiaTech on 05/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMemberTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *inviteImageView;
@end
