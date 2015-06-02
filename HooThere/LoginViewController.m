//
//  LoginViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"
#import "WhoThereViewController.h"
#import "FacebookSignUpViewController.h"
#import "AppDelegate.h"
#import "HootHereViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [CoreDataInterface wipeOutSavedData];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    loginButton.layer.cornerRadius=3;
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    //    self.navigationItem.hidesBackButton = YES;
    
    //    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonClicked)];
    //    self.navigationItem.rightBarButtonItem = doneButton;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [UtilitiesHelper changeTextFields:emailTextfield];
    [UtilitiesHelper changeTextFields:passwordTextfield];
    
    // Do any additional setup after loading the view.
    self.xmppStream.hostPort = 5222;
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream setHostName:kHostName];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [AppDel setupStream];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [emailTextfield becomeFirstResponder];
    //    [self fbDidLogout];
    //    _facebookInformationLoaded = TRUE;
    //    [self loadSignInWithFacebook];
}

- (void)viewDidAppear:(BOOL)animated {
    //    _facebookInformationLoaded = FALSE;
    
    //    CGRect newFrame;;
    //    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    //
    //    if (iOSDeviceScreenSize.height > 500)
    //    {
    //        newFrame = CGRectMake(20, 380, 280, 43);
    //    }
    //    else {
    //        newFrame = CGRectMake(20, 350, 280, 43);
    //    }
    //    loginview.frame = newFrame;
    //
    //    CGRect newButtonFrame = CGRectMake(0, 0, 280, 43);
    //    [[loginview.subviews objectAtIndex:0] setFrame:newButtonFrame];
}

#pragma Mark Facebook Methods--------------



//- (void)loadSignInWithFacebook {
//    loginview = [UtilitiesHelper loadFacbookButton:CGRectMake(20, 380, 280, 43)];
//    loginview.delegate = self;
//    [self.view addSubview:loginview];
//
//    NSLog(@"Array : %@",loginview.subviews);
//}
//
//- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
//                            user:(id<FBGraphUser>)user {
//    if (!_facebookInformationLoaded) {
//        NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/getFacebookUser",kwebUrl,[user objectForKey:@"id"]];
//        [_activityIndicator startAnimating];
//        [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
//         {
//             [_activityIndicator stopAnimating];
//             if (success) {
//                 BOOL validUser = [[jsonDict objectForKey:@"validUser"] boolValue];
//                 if (validUser) {
//                     NSString *userId=[NSString stringWithFormat:@"%@",[[jsonDict objectForKey:@"User"] objectForKey:@"id"]];
//                     if(userId.length > 0) {
//                         [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
//                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                         [defaults setBool:YES forKey:@"isloggedin"];
//                         [defaults synchronize];
//
//                         [CoreDataInterface saveUserInformation:[jsonDict objectForKey:@"User"]];
//                         [CoreDataInterface saveUserImageForUserId:userId];
//                         WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
//
//                         NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
//                         [navigationArray removeObjectAtIndex:1];
//                         [navigationArray addObject:whoThereView];
//                         [self.navigationController setViewControllers:navigationArray];
//                     }
//                 }
//                 else {
//                     [self signUpUsingFacebookAccount:user image:nil];
//                 }
//             }
//         }];
//    }
//}
//
//- (void)signUpUsingFacebookAccount:(id<FBGraphUser>)user image:(UIImage *)image {
//    _facebookInformationLoaded = TRUE;
//    FacebookSignUpViewController *facebookSignUpView = [self.storyboard instantiateViewControllerWithIdentifier:@"facebookSignUpView"];
//    facebookSignUpView.userInformation = user;
//    facebookSignUpView.userImage = image;
//    double delayInSeconds = 0.5;
//    NSLog(@"User data from facebook %@",user);
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
//        [navigationArray removeObjectAtIndex:1];
//        [navigationArray addObject:facebookSignUpView];
//        [self.navigationController setViewControllers:navigationArray];
//    });
//}
//
//- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
//    NSLog(@"You're logged in");
//    [[loginview.subviews objectAtIndex:2] setText:@"Log Out From Facebook"];
//}
//
//- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
//    NSLog(@"You're logged out");
//    [[loginview.subviews objectAtIndex:2] setText:@"Log In With Facebook"];
//}

-(void) fbDidLogout
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //    self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonClicked {
    [self.navigationController popViewControllerAnimated:NO];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField.tag == 1) {
//        if (string.length > 0 || (emailTextfield.text.length > 0 && passwordTextfield.text.length > 0)) {
//            if (string.length > 0 && passwordTextfield.text.length > 0) {
//                self.navigationItem.rightBarButtonItem.enabled = YES;
//            }
//            else {
//                self.navigationItem.rightBarButtonItem.enabled = NO;
//            }
//        }
//    }
//    else if (textField.tag == 2) {
//        if (string.length > 0 || (emailTextfield.text.length > 0 && passwordTextfield.text.length > 0)) {
//            if (string.length > 0 && emailTextfield.text.length > 0) {
//                self.navigationItem.rightBarButtonItem.enabled = YES;
//            }
//            else {
//                self.navigationItem.rightBarButtonItem.enabled = NO;
//            }
//        }
//    }
//    else {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
//
//    return YES;
//}

-(BOOL)validateEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[emailTextfield text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        [self checkPassword];
    }
}

- (void)checkPassword {
    if (!passwordTextfield.text.length > 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter the password minimum of 8 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else {
        self.xmppStream.hostPort = 5222;
        _xmppStream = [[XMPPStream alloc] init];
        [_xmppStream setHostName:kHostName];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [AppDel setupStream];
        
        [self connect];
    }
}

- (void)sendingLoginRequest {
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    
    NSLog(@"Device ID**** %@",oldTokenId);
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              emailTextfield.text, @"email",
                              passwordTextfield.text, @"password",
                              oldTokenId,@"deviceId",
                              @"ios",@"platform",
                              nil];
    
    
    NSLog(@"Login Detail %@",userData);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/login",kwebUrl];
    
    [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         NSLog(@"in success block");
         
         if (success) {
             NSString *userId=[NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"id"]];
             if(userId.length > 0) {
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setBool:YES forKey:@"isloggedin"];
                 [defaults synchronize];
                 
                 [CoreDataInterface saveUserInformation:jsonDict];
                 [CoreDataInterface saveUserImageForUserId:userId];
                 HootHereViewController *hooThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"hootHereView"];
                 //                     [self.navigationController pushViewController:whoThereView animated:NO];
                 
                 NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                 [navigationArray removeObjectAtIndex:1];
                 [navigationArray addObject:hooThereView];
                 [self.navigationController setViewControllers:navigationArray];
             }
             
         }
         else
             
             [_activityIndicator stopAnimating];
         
     }];
}
- (IBAction)loginButtonClicked:(UIButton *)sender {
    NSRange range=[emailTextfield.text rangeOfString:@"@"];
    NSString *userName=[[emailTextfield.text substringToIndex:range.location] lowercaseString];
    [[NSUserDefaults standardUserDefaults]  setValue:userName forKey:@"user_name"];
    [[NSUserDefaults standardUserDefaults] setValue:[[NSString stringWithFormat:@"%@",passwordTextfield.text] lowercaseString] forKey:@"user_password"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self checkEmailAndDisplayAlert];
    //    HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
    //    [self.navigationController pushViewController:homeView animated:YES];
}

#pragma mark Textfield Delegate -------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailTextfield) {
        [passwordTextfield becomeFirstResponder];
    }
    else if (textField == passwordTextfield) {
        [self loginButtonClicked:loginButton];
    }
    
    return YES;
}

#pragma Mark XMPP method Declration

- (BOOL)connect {
    self.xmppStream.hostName = kHostName;
    NSString *jabberID =[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"],kDomainName];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_password"];
    self.xmppStream.enableBackgroundingOnSocket=FALSE;
    if (![self.xmppStream isDisconnected]) {
        
        NSLog(@"connected XMPP");
        return YES;
    }
    NSLog(@" JID and password is %@ %@",jabberID,myPassword);
    
    if (jabberID == nil || myPassword == nil) {
        //   NSLog(@"connected to server nil JID ");
        return NO;
    }
    NSLog(@"connected to server ");
    [AppDel goOnline];
    [self.xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    
    self.password = myPassword;
    
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    if ([self.xmppStream isDisconnected]){
        NSLog(@"Is DisConnected");
        [self connect];
    }
    
    if ([self.xmppStream isConnecting]){
        NSLog(@"Is Connecting");
    }
    
    if ([self.xmppStream isConnected]){
        NSLog(@"Is Connected");
    }
    
    NSError *error = nil;
    
    /*   if (![[self xmppStream] registerWithElements:elements error:&error]) {
     NSLog(@"Registration error: %@", error);
     }
     */
    if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
    {
        
    }
}


- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"User Authenticated");
    [self sendingLoginRequest];
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    //   NSLog(@"authenticate fail %@",error);
    UIAlertView *wrongUser=[[UIAlertView alloc]initWithTitle:@"Authentication Failed" message:@"Wrong username or password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [wrongUser show];
    
    //console to the debug pannel
}

-(void)goOnline{
    
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    [AppDel discoverRoom];
}
@end
