//
//  SearchLocationViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 05/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@protocol SearchedLocationSelected <NSObject>
@required
- (void)locationSelected:(NSDictionary *)locationInfo;
// ... other methods here
@end

@interface SearchLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    IBOutlet UISearchBar *searchBarField;
    IBOutlet UITableView *searchTableView;
}

@property (nonatomic, weak) id <SearchedLocationSelected> delegate;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) Events         *thisEvent;
@property (nonatomic)BOOL isEditing;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

@end
