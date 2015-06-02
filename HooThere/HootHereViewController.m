//
//  HootHereViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "HootHereViewController.h"
#import "CustomTableViewCell.h"
#import "SearchViewController.h"
#import "CoreDataInterface.h"
#import "UtilitiesHelper.h"
#import "MyProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ResizeImage.h"
#import "AppDelegate.h"
#import "WhoThereViewController.h"
#import "UIImageView+WebCache.h"
#import "SingleUserChatViewController.h"
#import "AppDelegate.h"
#import "MessageTableViewCell.h"
#import "OverViewViewController.h"
@import GoogleMobileAds;
@interface HootHereViewController ()

@end

@implementation HootHereViewController {
    UIView *footerView;
  //  NSMutableArray *userList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [AddressBook getContactsFromAddressBook];
    });
    
    if([_fromWhereItCalled isEqualToString:@"HT"]){
        self.navigationItem.hidesBackButton = NO;
    }
    else {
        self.navigationItem.hidesBackButton = YES;
        NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
        [navigationArray removeObjectAtIndex:0];
        [self.navigationController setViewControllers:navigationArray];
    }

   // [self loadUserInChat];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFacebookFriends) name:@"kLoadFacebookFriends" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchListOfHootThereFriends) name:@"kPushUpdateFriendList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutButtonClicked) name:@"kLogoutButtonClicked" object:nil];

    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [CoreDataInterface deleteAllObject:@"Friends" andManagedOBC:appDelegate.managedObjectContext];
 
    [self.tabBarController.tabBar setTintColor:[UIColor purpleColor]];
     self.tabBarController.selectedIndex = 0;
    self.tabBarController.tabBar.hidden = NO;
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
//    singleTap.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:singleTap];

    
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
   [self.view bringSubviewToFront:_activityIndicator];
    [_activityIndicator startAnimating];

    textFieldBackground.layer.masksToBounds = YES;
    textFieldBackground.layer.cornerRadius = 14;

    [self loadSignInWithFacebook];
    
//    UISwipeGestureRecognizer *swipeRightOrange = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToRightWithGestureRecognizer:)];
//    swipeRightOrange.direction = UISwipeGestureRecognizerDirectionRight;
//    
//    UISwipeGestureRecognizer *swipeLeftOrange = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
//    swipeLeftOrange.direction = UISwipeGestureRecognizerDirectionLeft;
//    
//    [self.view addGestureRecognizer:swipeRightOrange];
//    [self.view addGestureRecognizer:swipeLeftOrange];
    
    
    
    if ([FBSession activeSession].isOpen) {
        
//        [UtilitiesHelper getFacebookFriends];
    }
  
}

- (void)logoutButtonClicked {
    self.tabBarController.selectedIndex = 0;
    self.tabBarController.tabBar.hidden = YES;
    
    OverViewViewController *overViewView = [self.storyboard instantiateViewControllerWithIdentifier:@"overViewView"];
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:overViewView, nil] animated:NO];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // AdMob Integration
    
// For Production Mode   self.adMobBannerView.adUnitID =@"ca-app-pub-4886788404179515/1267784183";
    
             // For Development Mode
    self.adMobBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.adMobBannerView.rootViewController = self;
    [self.adMobBannerView loadRequest:[GADRequest request]];
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    request.testDevices =@[[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"device_id"]]]; // Device ID
    [self.adMobBannerView loadRequest:request];
    
    
  //  [self loadUserInChat];
    CGRect newFrame = CGRectMake(20, 200, 280, 43);
    loginview.frame = newFrame;
    _facebookInformationLoaded = FALSE;
    _isAuthenticatedUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAuthenticatedUser"];
    
    CGRect newButtonFrame = CGRectMake(0, 0, 280, 43);
    [[loginview.subviews objectAtIndex:0] setFrame:newButtonFrame];
//    [self fetchListOfHootThereFriends];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
//    if (loggedIn) {
        [self tabButtonClicked:hooThereButton];
//    }
//    else {
//        self.tabBarController.selectedIndex = 2;
//    }
        [hootHereTableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)fetchListOfHootThereFriends {
    _listOfFriends =  [[NSMutableArray alloc] init];
    NSLog(@"%@",_listOfFriends);
    
    _listType=@"H";
    [hootHereTableView reloadData];
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/getAll?page=0",kwebUrl,userId];
    
    [UtilitiesHelper fetchListOfHootThereFriends:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        
        [_activityIndicator stopAnimating];
        
        if (success) {
            AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
            [CoreDataInterface deleteAllObject:@"Friends" andManagedOBC:appDelegate.managedObjectContext];
            [CoreDataInterface saveFriendList:[jsonDict objectForKey:@"Friends"]];
            [self updateFriendsTableView];
        }
    }];
}

- (void)updateFriendsTableView {
    _listOfFriends =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:nil andSortkey:@"fullName" isSortAscending:YES];
   // NSLog(@"%@",_listOfFriends);
    
    if (!_listOfFriends.count > 0) {
        hootHereTableView.hidden = YES;
        [self aloneView:NO];
    }
    else {
        hootHereTableView.hidden = NO;
        [self aloneView:YES];
    }
    _listType=@"H";
    [hootHereTableView reloadData];
}

- (IBAction)tabButtonClicked:(UIButton *)button {
 //   NSLog(@"tab button Clicked");
    if (button.tag == 4) {
         _listType = @"H";
        CGRect newFrame = tabLineView.frame;
        newFrame.origin.x = hooThereButton.frame.origin.x;
        
        [UIView animateWithDuration:0.6 animations:^(void){
            tabLineView.frame = newFrame;
        }];
          loginview.hidden = YES;
        SearchViewController *searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
        [self presentViewController:searchView animated:YES completion:nil];
        return;
    }
    [self resetSearch];
    CGRect newFrame = tabLineView.frame;
        newFrame.origin.x = button.frame.origin.x;
        
    [UIView animateWithDuration:0.6 animations:^(void){
            tabLineView.frame = newFrame;
    }];
    
    if(button.tag == 1){
        _listType = @"H";
        loginview.hidden = YES;
        [self aloneView:YES];
        [self fetchListOfHootThereFriends];
        _facebookSelected = FALSE;
//        [self aloneView:NO];
    }
    else if(button.tag == 2){
        [self resetSearch];
        _listType = @"F";
        [self aloneView:YES];
       // NSLog(@"facebook clicked");
        [self performSelector:@selector(facebookFriends) withObject:nil afterDelay:0.1];
    }
    else if(button.tag == 3){
        _listType = @"C";
        [self getContactListFromCoreData];
        _facebookSelected = FALSE;
        loginview.hidden = YES;
        [self aloneView:YES];
    }
}

- (void)aloneView:(BOOL)value {
    searchLabel.hidden = value;
    aloneImage.hidden = value;
    aloneLabel.hidden = value;
}


- (void)getContactListFromCoreData {
    NSMutableArray *contacts =  [CoreDataInterface searchObjectsInContext:@"Contacts" andPredicate:nil andSortkey:@"name" isSortAscending:YES];
    
    _listOfFriends = contacts;
    hootHereTableView.hidden = NO;
    _listType=@"C";
    [hootHereTableView reloadData];
}

- (void)loadSignInWithFacebook {
    loginview = [UtilitiesHelper loadFacbookButton:CGRectMake(20, 200, 280, 43)];
    loginview.delegate = self;
    [self.view addSubview:loginview];
    
    loginview.hidden = YES;
   // NSLog(@"Array : %@",loginview.subviews);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
   // NSLog(@"%@",[user objectForKey:@"user_friends"]);
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if ([userInfo.facebookId isEqualToString:[NSString stringWithFormat:@"%@",[user objectForKey:@"id"]]]) {
        _isAuthenticatedUser = TRUE;
        [UtilitiesHelper getFacebookFriends];
        return;
    }
    if (_facebookInformationLoaded) {
        return;
    }
    _facebookInformationLoaded = TRUE;
    _profilePictureView.profileID = [user objectForKey:@"id"];
    self.view.userInteractionEnabled = NO;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [user objectForKey:@"id"], @"facebookId",nil];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/updateFacebookId",kwebUrl,uid];
    [_activityIndicator startAnimating];
    
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         self.view.userInteractionEnabled = YES;
         
         [_activityIndicator stopAnimating];
         if (success) {
             _isAuthenticatedUser = TRUE;
             [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isAuthenticatedUser"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             NSString *userId=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"id"]];
             [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
             id imageName = [jsonDict objectForKey:@"profile_picture"];
             if (imageName == nil || [imageName isEqual:[NSNull null]]) {
                 [self performSelector:@selector(uploadImageForUser) withObject:nil afterDelay:1];
             }
             [CoreDataInterface saveUserInformation:[jsonDict objectForKey:@"User"]];
             [CoreDataInterface saveUserImageForUserId:userId];
             [UtilitiesHelper getFacebookFriends];
         }
         else {
             _isAuthenticatedUser = FALSE;
             [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isAuthenticatedUser"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             if ([_listType isEqualToString:@"F"]) {
                 hootHereTableView.hidden = YES;
                 loginview.hidden = NO;
             }
         }
     }];
}

- (void)uploadImageForUser {
    UIImage *image;
    for (UIImageView *imageView in _profilePictureView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            image = [imageView image];
        }
    }
 //   NSLog(@"Image length : %ld",UIImagePNGRepresentation(image).length);
    [UtilitiesHelper uploadImage:UIImagePNGRepresentation(image)];
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
 //   NSLog(@"You're logged in");
    
    [[loginview.subviews objectAtIndex:2] setText:@"Log Out From Facebook"];
    loginView.hidden = YES;
    hootHereTableView.hidden = NO;
    [_activityIndicator startAnimating];
    //    [self.view setUserInteractionEnabled:NO];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
 //   NSLog(@"You're logged out");
    _facebookInformationLoaded = FALSE;
    [[loginview.subviews objectAtIndex:2] setText:@"Connect with Facebook"];
//    loginView.hidden = NO;
    hootHereTableView.hidden = YES;
}

- (void)loadFacebookFriends {
    [_activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    
    NSMutableArray *facebookFriends =  [CoreDataInterface searchObjectsInContext:@"Facebook" andPredicate:nil andSortkey:@"name" isSortAscending:YES];
    if (!facebookFriends.count > 0) {
        return;
    }
    if ([_listType isEqualToString:@"F"]) {
        _listOfFriends = facebookFriends;
        [hootHereTableView reloadData];
    }
}

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"Test");
    }];
}

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"Test");
    }];
}



- (void)facebookFriends {
    
    if (!_facebookSelected) {
        searchLabel.hidden = YES;
        aloneImage.hidden = YES;
        aloneLabel.hidden = YES;
        _listOfFriends = [[NSMutableArray alloc] init];
        
        
        _listType = @"F";
        [hootHereTableView reloadData];
        if ([FBSession activeSession].isOpen) {
            [self loadFacebookFriends];
            loginview.hidden = YES;
            hootHereTableView.hidden = NO;
        }
        else {
            loginview.hidden = NO;
            hootHereTableView.hidden = YES;
        }
        
        if (_isAuthenticatedUser) {
            [UtilitiesHelper getFacebookFriends];
            hootHereTableView.hidden = NO;
            loginview.hidden = YES;

        }
        else {
            hootHereTableView.hidden = YES;
            loginview.hidden = NO;
        }
        
        _facebookSelected = TRUE;
    }
}

- (void)resetSearch {
    _searching = FALSE;
    [self.view endEditing:YES];
    searchBarField.text = @"";
    searchBarField.showsCancelButton = NO;
    _searchArray = [[NSMutableArray alloc] init];
}

- (IBAction)hooThereButtonClicked:(id)sender {
    [self resetSearch];
    
    _listOfFriends = [[NSMutableArray alloc] init];
    [self fetchListOfHootThereFriends];
    [hootHereTableView reloadData];
    
    CGRect newFrame = tabLineView.frame;
    newFrame.origin.x = hooThereButton.frame.origin.x;
    newFrame.size.width = hooThereButton.frame.size.width;
  //  NSLog(@"Origin X : %f",newFrame.origin.x);
    if (newFrame.origin.x < 0) {
        return;
    }
    [UIView animateWithDuration:0.6 animations:^(void){
        tabLineView.frame = newFrame;
    }];
    _listType = @"H";
    
    _facebookSelected = FALSE;
    

}


- (IBAction)facebookButtonClicked:(id)sender {
    [self resetSearch];
    
    [self performSelector:@selector(facebookFriends) withObject:nil afterDelay:0.5];
}

- (IBAction)contactsButtonClicked:(id)sender {
    [self resetSearch];
    
    _listOfFriends = [[NSMutableArray alloc] init];
    [hootHereTableView reloadData];
    
    CGRect newFrame = tabLineView.frame;
    newFrame.origin.x = contactsButton.frame.origin.x;
    newFrame.size.width = contactsButton.frame.size.width;
  //  NSLog(@"Origin X : %f",newFrame.origin.x);
    if (newFrame.origin.x < 0) {
        return;
    }
    [UIView animateWithDuration:0.6 animations:^(void){
        tabLineView.frame = newFrame;
    }];
    _listType = @"C";
    [self getContactListFromCoreData];
    _facebookSelected = FALSE;
}


#pragma mark Tableview Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([_listType isEqualToString:@"C"]) {
        return 1;
    }
    else {
    return 1;
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
       if ([_listType isEqualToString:@"C"]) {
        if (section==0) {
            if (_searching) {
                return [_searchArray count];
            }
            else {
                return [_listOfFriends count];
            }
        }
    }
    else {
        NSString *string=@"F";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(status == %@)",string];
        NSArray *searchedArray = [_listOfFriends filteredArrayUsingPredicate:predicate];
        _statusFFriends =[NSMutableArray arrayWithArray:searchedArray];

    if (section==0) {
        if (_searching) {
            return [_searchArray count];
        }
        else {
            return [_listOfFriends count];
        }
    }
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell;
    static NSString *cellIdentifier = @"contactsCell";
    
    cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.iconImageview.layer.masksToBounds = YES;
    cell.iconImageview.layer.cornerRadius = cell.iconImageview.frame.size.width / 2;
    
    cell.inviteForEventButton.hidden=YES;
    cell.statusIcon.hidden=YES;
    cell.statusImage.hidden = YES;
    cell.sendFriendRequestButton.hidden = YES;
     cell.rejectFriendRequestButton.hidden = YES;
    cell.eventPlaceLabel.hidden = YES;
    cell.titleLabel.hidden = NO;
    id contactInfo;
    if (_searching) {
        contactInfo = [_searchArray objectAtIndex:indexPath.row];
    }
    else {
        contactInfo = [_listOfFriends objectAtIndex:indexPath.row];
    }
     [cell.inviteForEventButton addTarget:self action:@selector(inviteSingleFriend:) forControlEvents:UIControlEventTouchUpInside];
    cell.hootHereButton.hidden = YES;
    //cell.titleLabel.text = [contactInfo objectForKey:@"User"];
    //cell.titleLabel.text = [[contactInfo objectForKey:@"friend"] objectForKey:@"firstName"];
    
  //  NSLog(@"Contact Info %@",contactInfo);
    [cell.backgroundImageview setHidden:YES];
    cell.backgroundImageview.hidden = YES;
    cell.subTitleLabel.hidden = YES;

    if ([_listType isEqualToString:@"F"]) {
        cell.statusImage.hidden = YES;
        cell.titleLabel.text = [contactInfo name];
        [cell.iconImageview setHidden:NO];
        [cell.subTitleLabel setHidden:YES];
        
        [cell.inviteForEventButton setHidden:NO];
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        if (![[contactInfo imageurl] isEqual:[NSNull null]] && [contactInfo imageurl] != nil) {
            NSURL *url = [[NSURL alloc] initWithString:[contactInfo imageurl]];
            [cell.iconImageview sd_setImageWithURL:url placeholderImage:image];
        }
        else {
            cell.iconImageview.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        }
        
        if ([_listOfFacebookInvites containsObject:contactInfo]) {
            cell.backgroundImageview.image = [UIImage imageNamed:@"invite-blue.png"];
        }
        else {
            cell.backgroundImageview.image = [UIImage imageNamed:@"invite-border.png"];
        }
        
        BOOL isFound = [self checkFacebookUserInYouFriendList:[contactInfo userid]];
        
        if (isFound) {
            cell.inviteForEventButton.hidden=NO;
            cell.sendFriendRequestButton.hidden = YES;
        }
        else {
            cell.inviteForEventButton.hidden=YES;
            [cell.sendFriendRequestButton addTarget:self action:@selector(sendFriendRequestToFacebookUser:) forControlEvents:UIControlEventTouchUpInside];
            cell.sendFriendRequestButton.hidden = NO;
        }
        cell.inviteForEventButton.tag = indexPath.row;
        cell.sendFriendRequestButton.tag = indexPath.row;
    }
    else if ([_listType isEqualToString:@"C"]) {

        cell.statusIcon.hidden=NO;
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        [cell.inviteForEventButton setHidden:NO];
        if ([[contactInfo imageData] length] > 0) {
            cell.iconImageview.image = [ResizeImage squareImageWithImage:[UIImage imageWithData:[contactInfo imageData]] scaledToSize:CGSizeMake(100, 100)];
        }
        else {
            cell.iconImageview.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        }
        [cell.subTitleLabel setHidden:NO];
        cell.titleLabel.text = [contactInfo name];
        if ([[contactInfo number] length] > 0) {
            cell.subTitleLabel.text = [contactInfo number];
              cell.statusIcon.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:nil for:@"phone"]];
            [cell.statusIcon setFrame:CGRectMake(cell.statusIcon.frame.origin.x, cell.statusIcon.frame.origin.y, 8,12)];
            
        }
        else if ([[contactInfo email] length] > 0){
            cell.subTitleLabel.text = [contactInfo email];
            cell.statusIcon.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:nil for:@"email"]];
             [cell.statusIcon setFrame:CGRectMake(cell.statusIcon.frame.origin.x, cell.statusIcon.frame.origin.y, 12,8)];
        }
        else {
            cell.subTitleLabel.text = @"";
        }
    }
    else if([_listType isEqualToString:@"H"]) {
        cell.eventPlaceLabel.hidden = NO;
        cell.titleLabel.hidden = YES;
        cell.iconImageview.hidden = NO;
        cell.backgroundImageview.hidden = YES;
        cell.rejectFriendRequestButton.hidden=YES;

        cell.statusIcon.hidden=NO;
        
        
    
        [cell.statusIcon setFrame:CGRectMake(cell.statusIcon.frame.origin.x, cell.statusIcon.frame.origin.y, 10,10)];
        
     //   NSLog(@"%@",[contactInfo entity ]);
        //if([contactInfo entity ]){
        id imageName = [contactInfo profile_picture];

        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        cell.iconImageview.image= image;
        
        if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[contactInfo friendId]];
            [cell.iconImageview sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];

        }
        
        cell.eventPlaceLabel.text = [contactInfo fullName];
        [cell.subTitleLabel setHidden:YES];
    
        

        
        cell.rejectFriendRequestButton.tag= indexPath.row;
        cell.sendFriendRequestButton.tag = indexPath.row;
        cell.inviteForEventButton.tag=indexPath.row;

        cell.subTitleLabel.hidden = YES;
        cell.statusIcon.hidden=YES;
   
        if ([[contactInfo status] isEqualToString:@"P"]) {
            cell.statusImage.hidden = NO;
//             cell.statusIcon.hidden=YES;

        }
        else if ([[contactInfo status] isEqualToString:@"A"]) {
            cell.statusImage.hidden = YES;
            [cell.sendFriendRequestButton addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
            
              [cell.rejectFriendRequestButton addTarget:self action:@selector(rejectFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.sendFriendRequestButton.hidden = NO;
            cell.rejectFriendRequestButton.hidden = NO;
 
//            cell.statusIcon.hidden=YES;

            
        }
        else {
//            cell.subTitleLabel.hidden = NO;
            cell.inviteForEventButton.hidden=NO;
            cell.hootHereButton.hidden = NO;
            cell.hootHereButton.tag = indexPath.row;
            
//            NSString *availabilityStatus = [contactInfo availabilityStatus];
//            if (availabilityStatus !=  nil && ![availabilityStatus isEqual:[NSNull null]] && ![availabilityStatus isEqualToString:@"<null>"]) {
//                cell.subTitleLabel.text = availabilityStatus;
//                cell.statusIcon.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:availabilityStatus for:@"status"]];
//                
//            }
//            else {
//                cell.subTitleLabel.text = @"Looking for plans";
//                cell.statusIcon.image=[UIImage imageNamed:@"makeplan.png"];
//            }
        }
    }
       return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) {
        
    NSLog(@"_listType %@",_listType);
    if ([_listType isEqualToString:@"H"])
    {
        id contactInfo;
        if (_searching) {
            contactInfo = [_searchArray objectAtIndex:indexPath.row];
        }
        else {
            contactInfo = [_listOfFriends objectAtIndex:indexPath.row];
        }
        
        MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
        myProfileView.friendId = [contactInfo friendId];
        myProfileView.isFromNavigation = TRUE;
        myProfileView.isUser = NO;
        myProfileView.friendData = [UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:contactInfo type:nil];
        myProfileView.frienshipStatus = [contactInfo status];
        if([[contactInfo status] isEqualToString:@"F"]) {
            myProfileView.isFriend=YES;
        }
        else if([[contactInfo status] isEqualToString:@"A"]) {
            myProfileView.isFriend = YES;
        }
        else {
            myProfileView.isFriend=NO;
        }
//        self.title=@"User Profile";
        myProfileView.fromWhereCalled=@"HH";

        [self.navigationController pushViewController:myProfileView  animated:YES];
    }
    }
    else if (indexPath.section==1) {
        MessageTableViewCell *cell = (MessageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
      //  NSRange emailRange =[cell.rejectFriendRequestButton.titleLabel.text rangeOfString:@"@"];
     //   NSString *userNameXMPP=[cell.rejectFriendRequestButton.titleLabel.text substringToIndex:emailRange.location];
        SingleUserChatViewController *singleUserChatVC=[[SingleUserChatViewController alloc]initWithUser:cell.frndName.text];
        singleUserChatVC.titleText=cell.frndName.text;
        singleUserChatVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:singleUserChatVC animated:YES];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    footerView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,1)];
    footerView.backgroundColor=[UIColor clearColor];
    return footerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section==0) {
        return 0;
    }
    else if (section==1){
    return 5.0f;
    }
    return 5.0f;
}

- (BOOL)checkFacebookUserInYouFriendList:(NSString *)userId {
    BOOL isFound = FALSE;
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(facebookId == %@)",userId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
    
    if (retData.count > 0) {
        isFound = TRUE;
    }
    return isFound;
}

- (IBAction)hootAFriendButtonClicked:(UIButton *)hootAFriendButton {
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];

    NSMutableArray *array ;
    if (_searching) {
        array = _searchArray;
    }
    else {
        array = _listOfFriends;
    }
    Friends *userInfo = [array objectAtIndex:hootAFriendButton.tag];
    NSString *toUserID = [userInfo friendId];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/hoot/%@",kwebUrl,userId,toUserID ];
    
 //   NSLog(@"accepting Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];

         if (success) {
             NSString *message = [NSString stringWithFormat:@"You have hooted %@.",userInfo.fullName];
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
     }];
}


-(void)inviteSingleFriend:(UIButton *)inviteForEventButton{
    // NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
      //  NSLog(@"%li",(long)inviteForEventButton.tag);
        
        NSMutableArray *array ;
        if (_searching) {
            array = _searchArray;
        }
        else {
            array = _listOfFriends;
        }
        id userInfo = [array objectAtIndex:inviteForEventButton.tag];
    
     NSMutableDictionary *friendInfo = [[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:userInfo type:nil] mutableCopy];
    
    NSArray *friendArray=[[NSArray alloc]initWithObjects:friendInfo, nil];
    NSDictionary *dictionaryInfo;
    
    if([_listType isEqualToString:@"H"])
    {
     dictionaryInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                    
                                    friendArray,@"hoothere",
                                    nil];
    }
    else if([_listType isEqualToString:@"C"])
    {
        dictionaryInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                         
                         friendArray,@"contacts",
                         nil];
    }
    else
    {
        dictionaryInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                         
                         friendArray,@"facebook",
                         nil];
    }
    
 //   NSLog(@"dictionary Info %@",dictionaryInfo );

    WhoThereViewController *whoThereView=[self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
    whoThereView.friendToInviteInfo=dictionaryInfo;
    whoThereView.fromWhereCalled=@"HT";
    whoThereView.title = @"My Upcoming Events";
    [self.navigationController pushViewController:whoThereView  animated:YES];

}

- (void)sendFriendRequestToFacebookUser:(UIButton * )sendFriendButton {
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
   // NSLog(@"%ld",(long)sendFriendButton.tag);
    
    Facebook *userInfo;
    if (_searching) {
        userInfo = [_searchArray objectAtIndex:sendFriendButton.tag];
    }
    else {
        userInfo = [_listOfFriends objectAtIndex:sendFriendButton.tag];
    }
    NSString *toUserId = [userInfo userid];
    
   // NSLog(@"%@",toUserId);
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/add/%@",kwebUrl,userId,toUserId];
    
    NSDictionary *payload = [[NSDictionary alloc] initWithObjectsAndKeys:@"F",@"type",nil];
    
  //  NSLog(@"sending Request to %@",urlString);
    [UtilitiesHelper getResponseFor:payload url:[NSURL URLWithString: urlString] requestType:@"PUT"
                   complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         
         if (success) {
             NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:jsonDict];
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Your friend request has been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             [userInfo setObject:@"P" forKey:@"status"];
             [userInfo setObject:[userInfo objectForKey:@"id"] forKey:@"id"];
             NSDictionary *friendInfo = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo,@"friend",@"P",@"status", nil];
             [CoreDataInterface saveFriendList:[NSArray arrayWithObject:friendInfo]];
             [hootHereTableView reloadData];
         }
     }];
}

-(void)acceptFriendRequest:(UIButton * )sendFriendButton {
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
   // NSLog(@"%li",(long)sendFriendButton.tag);
    
    NSMutableArray *array ;
    if (_searching) {
        array = _searchArray;
    }
    else {
        array = _listOfFriends;
    }
    Friends *userInfo = [array objectAtIndex:sendFriendButton.tag];
    NSString *toUserID = [userInfo friendId];

    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/accept/%@",kwebUrl,userId,toUserID ];
    
   // NSLog(@"accepting Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user is added to your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];

            
             
             [self fetchListOfHootThereFriends];
             _listType=@"H";
             [hootHereTableView reloadData];

             userInfo.status = @"F";
             [CoreDataInterface saveAll];
             [self updateFriendsTableView];

         }
     }];
}

-(void)rejectFriendRequest:(UIButton * )rejectFriendButton {
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSMutableArray *array ;
    if (_searching) {
        array = _searchArray;
    }
    else {
        array = _listOfFriends;
    }
    Friends *userInfo = [array objectAtIndex:rejectFriendButton.tag];
    NSString *toUserID = [userInfo friendId];
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/reject/%@",kwebUrl,userId,toUserID ];
    [_activityIndicator startAnimating];
   // NSLog(@"Rejecting Request to %@",urlString);

    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             

             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",toUserID];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             if ([retData count] > 0)
             {[_activityIndicator stopAnimating];
                 [CoreDataInterface deleteThisFriend:[retData objectAtIndex:0]];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user is removed from your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
             }
             [self updateFriendsTableView];
         }
     }];
}

#pragma mark Search Delegates-----------------

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString *dictionaryKey = @"name";
    NSPredicate *entitySearchPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", dictionaryKey, searchText];
    
    NSArray *filteredarray = [[NSArray alloc] init];
    
    if ([_listType isEqualToString:@"F"]) {
        filteredarray =  [CoreDataInterface searchObjectsInContext:@"Facebook" andPredicate:entitySearchPredicate andSortkey:@"name" isSortAscending:YES];
     //   NSLog(@"%@", filteredarray);
    }
    else if ([_listType isEqualToString:@"C"]) {
        filteredarray =  [CoreDataInterface searchObjectsInContext:@"Contacts" andPredicate:entitySearchPredicate andSortkey:@"name" isSortAscending:YES];
      //  NSLog(@"%@", filteredarray);
    }
    else {
        NSString *dictionaryKey1 = @"firstName";
        NSPredicate *entitySearchPredicate1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", dictionaryKey1, searchText];
        filteredarray =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate1 andSortkey:@"firstName" isSortAscending:YES];
      //  NSLog(@"%@", filteredarray);
    }
    
    
    _searchArray = [[NSMutableArray alloc] initWithArray:filteredarray];
    
  //  NSLog(@"Search Array : %@",_searchArray);
    
    if (_searchArray.count > 0) {
        hootHereTableView.hidden = NO;
        [hootHereTableView reloadData];
    }
    else {
        hootHereTableView.hidden = YES;
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    hootHereTableView.hidden = NO;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    _searching = TRUE;
    
    [hootHereTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  //  NSLog(@"Search Clicked");
    [self.view endEditing:YES];
    //    searchBar.showsCancelButton = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  //  NSLog(@"Cancel Clicked");
    [self resetSearch];
    //_listType=@"H";
    [hootHereTableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchBar.text
                               scope:nil];
}


@end
