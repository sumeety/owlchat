//
//  SelectLocationTypeViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 18/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"
#import "SearchLocationViewController.h"
#import "EventLocationViewController.h"

@protocol UpdateLocationInfo <NSObject>
@required
- (void)updateLocationInformation:(NSDictionary *)locationInfo;
// ... other methods here
@end

@interface SelectLocationTypeViewController : UIViewController <SearchedLocationSelected, NewLocationEntered>{
    
    IBOutlet UIButton               *manualSearchButton;
    IBOutlet UIButton               *googleSearchButton;
}

- (IBAction)manualSearchButtonClicked:(id)sender;
- (IBAction)googleSearchButtonClicked:(id)sender;

@property (strong, nonatomic) Events    *thisEvent;
@property (nonatomic)BOOL isEditing;
@property (nonatomic, weak) id <UpdateLocationInfo> delegate;

@end
