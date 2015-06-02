//
//  GroupMemberTableViewCell.m
//  Hoothere
//
//  Created by UnoiaTech on 05/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "GroupMemberTableViewCell.h"

@implementation GroupMemberTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImageView.layer.cornerRadius=50;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
