//
//  OverViewViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface OverViewViewController : UIViewController <UIScrollViewDelegate, FBLoginViewDelegate> {
    
    IBOutlet UIButton *hooThereLoginButton;
    IBOutlet UIButton *getStartedButton;
    FBLoginView                 *loginview;
}

@property (weak, nonatomic) IBOutlet UIScrollView  *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic)       BOOL     pageControlBeingUsed;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic)         BOOL      facebookInformationLoaded;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)gettingStartedButtonClicked:(id)sender;
- (IBAction)changePage;


@end
