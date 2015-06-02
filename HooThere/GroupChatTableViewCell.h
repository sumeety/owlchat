//
//  GroupChatTableViewCell.h
//  Hoothere
//
//  Created by UnoiaTech on 03/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatTableViewCell : UITableViewCell
@property (nonatomic,strong) UITextView *messageContentView;
@property (nonatomic,strong) UILabel *senderAndTimeLabel;
@property (nonatomic,strong) UIView *labelBackgroundView;
@end
