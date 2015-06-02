//
//  MessageTableViewCell.m
//  KiteApp
//
//  Created by UnoiaTech on 22/12/14.
//  Copyright (c) 2014 UnoiaTech. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

- (void)awakeFromNib {
    self.userFrndImage.layer.masksToBounds = YES;
    self.userFrndImage.layer.cornerRadius = self.userFrndImage.frame.size.width / 2;
    self.messageCountLabel.layer.cornerRadius = self.messageCountLabel.frame.size.width / 2;
    self.messageCountLabel.clipsToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse
{
    [super prepareForReuse];

}
@end
