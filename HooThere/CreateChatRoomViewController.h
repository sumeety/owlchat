//
//  CreateChatRoomViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 04/05/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateChatRoomViewController : UIViewController <UITextFieldDelegate>
- (IBAction)doneTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *groupNameTextField;

@end
