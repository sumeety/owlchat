//
//  OverViewViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "OverViewViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "FacebookSignUpViewController.h"
#import "EventGeoFenceViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "HomeViewController.h"
#import "SearchLocationViewController.h"
#import "MyProfileViewController.h"
#import "WhoThereViewController.h"
#import "HootHereViewController.h"
@interface OverViewViewController ()

@end

@implementation OverViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];

    UIImage *image1 = [UIImage imageNamed:@"hoothere-logo.png"];
    UIImage *image2 = [UIImage imageNamed:@"3.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"4.jpg"];
    UIImage *image4 = [UIImage imageNamed:@"1.jpg"];
    UIImage *image5 = [UIImage imageNamed:@"212.jpg"];
    UIImage *image6 = [UIImage imageNamed:@"5.jpg"];

    NSArray *colors = [NSArray arrayWithObjects:image1,image2,image3,image4,image5,image6, nil];
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *subview = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollView.frame.size.width * i) +30,0, 260, self.scrollView.frame.size.height - 80)];
        subview.image = [colors objectAtIndex:i];
        subview.contentMode = UIViewContentModeScaleAspectFit;
//        subview.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:subview];
    }
    
    _pageControl.hidden = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
    [defaults synchronize];
    NSLog(@"logginIn %s",(loggedIn?"YES":"NO"));
    if (loggedIn) {
       HootHereViewController  *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"hootHereView"];
//        NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
//        [navigationArray removeLastObject];
//        [navigationArray addObject:whoThereView];
        [self.navigationController pushViewController:whoThereView animated:NO];//[NSArray arrayWithObjects:whoThereView, nil] animated:NO];
    }
    else {
        self.tabBarController.tabBar.hidden = YES;
        [self loadSignInWithFacebook];
    }
    
  
    hooThereLoginButton.layer.borderWidth=1.0f;
     hooThereLoginButton.layer.borderColor=[UIColor purpleColor].CGColor;
    hooThereLoginButton.layer.cornerRadius=3;
    
    getStartedButton.layer.cornerRadius=3;
    
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colors.count, self.scrollView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    //    [self fbDidLogout];
    //    _facebookInformationLoaded = TRUE;
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    _facebookInformationLoaded = FALSE;
    
    CGRect newFrame;;
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    if (iOSDeviceScreenSize.height > 500)
    {
        newFrame = CGRectMake(20, self.view.frame.size.height-55, 280, 40);
    }
    else {
        newFrame = CGRectMake(20, self.view.frame.size.height-55, 280, 40);
    }
    loginview.frame = newFrame;
    
    CGRect newButtonFrame = CGRectMake(0, 0, 280, 40);
    [[loginview.subviews objectAtIndex:0] setFrame:newButtonFrame];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)loginButtonClicked:(id)sender {
    LoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [self .navigationController pushViewController:loginView animated:YES];
//    SearchLocationViewController *searchLocationView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchLocationView"];
//    [self presentViewController:searchLocationView animated:YES completion:nil];
}

- (IBAction)gettingStartedButtonClicked:(id)sender {
    SignUpViewController *signUpView = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpView"];
    [self .navigationController pushViewController:signUpView animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    _pageControlBeingUsed = YES;
}

- (void)setTransitionView:(NSString *)subType {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = subType;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

#pragma Mark Facebook Methods--------------



- (void)loadSignInWithFacebook {
    loginview = [UtilitiesHelper loadFacbookButton:CGRectMake(20, self.view.frame.size.height-55, 280, 40)];
    loginview.delegate = self;
    [self.view addSubview:loginview];
    
    NSLog(@"Array : %@",loginview.subviews);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
    [defaults synchronize];
    NSLog(@"logginIn %s",(loggedIn?"YES":"NO"));
    if (loggedIn) {
        return;
    }
    if (!_facebookInformationLoaded) {
        _profilePictureView.profileID = [user objectForKey:@"id"];
        self.view.userInteractionEnabled = NO;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/getFacebookUser?deviceId=%@&platform=ios",kwebUrl,[user objectForKey:@"id"],oldTokenId];
        [_activityIndicator startAnimating];
        [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             self.view.userInteractionEnabled = YES;

             [_activityIndicator stopAnimating];
             if (success) {
                 BOOL validUser = [[jsonDict objectForKey:@"validUser"] boolValue];
                 if (validUser) {
                     NSString *userId=[NSString stringWithFormat:@"%@",[[jsonDict objectForKey:@"User"] objectForKey:@"id"]];
                     if(userId.length > 0) {
                         [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                         id imageName = [[jsonDict objectForKey:@"User"] objectForKey:@"profile_picture"];
                         if (imageName == nil || [imageName isEqual:[NSNull null]]) {
                             [self performSelector:@selector(uploadImageForUser) withObject:nil afterDelay:2];
                         }
                         else if ([imageName isEqualToString:@""]) {
                             [self performSelector:@selector(uploadImageForUser) withObject:nil afterDelay:2];
                         }
                         else {
                             [CoreDataInterface saveUserImageForUserId:userId];
                         }
//                         [[NSUserDefaults standardUserDefaults]
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         [defaults setBool:YES forKey:@"isloggedin"];
                         id userFbId = [NSString stringWithFormat:@"%@",[[jsonDict objectForKey:@"User"] objectForKey:@"facebookId"]];
                         id fbId = [NSString stringWithFormat:@"%@",[user objectForKey:@"id"]];
                         if ([userFbId isEqualToString:fbId]) {
                             [defaults setBool:TRUE forKey:@"isAuthenticatedUser"];
                         }
                         [defaults synchronize];
                         
                         [CoreDataInterface saveUserInformation:[jsonDict objectForKey:@"User"]];
                         NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                         
                         [CoreDataInterface saveUserImageForUserId:userId];
                         HootHereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"hootHereView"];
                         NSLog(@"navigation array count %lu",(unsigned long)navigationArray.count);
                         if (navigationArray.count == 2) {
                             [navigationArray removeObjectAtIndex:1];
                             [navigationArray addObject:whoThereView];
                             [self.navigationController setViewControllers:navigationArray];
                         }else {
                             [self.navigationController pushViewController:whoThereView animated:YES];
                         }
                         [UtilitiesHelper getFacebookFriends];

                     }
                 }
                 else {
                     [self signUpUsingFacebookAccount:user image:nil];
                 }
             }
         }];
    }
}

- (void)uploadImageForUser {
    UIImage *image;
    for (UIImageView *imageView in _profilePictureView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            image = [imageView image];
        }
    }
    NSLog(@"Image length : %ld",UIImagePNGRepresentation(image).length);
    [UtilitiesHelper uploadImage:UIImagePNGRepresentation(image)];
}

- (void)signUpUsingFacebookAccount:(id<FBGraphUser>)user image:(UIImage *)image {
    _facebookInformationLoaded = TRUE;
    FacebookSignUpViewController *facebookSignUpView = [self.storyboard instantiateViewControllerWithIdentifier:@"facebookSignUpView"];
    facebookSignUpView.userInformation = user;
    facebookSignUpView.userImage = image;
    [self.navigationController pushViewController:facebookSignUpView animated:YES];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"You're logged in");
    [[loginview.subviews objectAtIndex:2] setText:@"Log Out From Facebook"];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"You're logged out");
    [[loginview.subviews objectAtIndex:2] setText:@" Connect With Facebook"];
}

@end
