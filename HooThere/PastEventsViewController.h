//
//  PastEventsViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 29/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PastEventsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView            *eventTableView;
}

@property (nonatomic, strong) NSMutableArray        *listOfEvents;

@property (nonatomic) BOOL      noEvents;
@property (nonatomic) BOOL      noRequest;
@property (nonatomic) BOOL      isRefreshed;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;


- (IBAction)hooCameButtonClicked:(UIButton *)sender;
- (IBAction)goingThereButtonClicked:(UIButton *)sender;
- (IBAction)invitedButtonClicked:(UIButton *)sender;
- (IBAction)placeButtonClicked:(id)sender;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
