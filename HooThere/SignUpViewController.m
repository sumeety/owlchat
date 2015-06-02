//
//  SignUpViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "SignUpViewController.h"
#import "HomeViewController.h"
#import "UtilitiesHelper.h"
#import "FacebookSignUpViewController.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"
#import "ChangeNumberViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "WhoThereViewController.h"
#import "AppDelegate.h"
#import "HootHereViewController.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CoreDataInterface wipeOutSavedData];
    
//    [self getCountryCode];
    
    // Do any additional setup after loading the view.
    _numberCheckAnimator.hidden = YES;

    // XMPPStreamDelegate added here, 2-April-2015, Unoiatech.
    _xmppStream.hostPort = 5222;
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream setHostName:kHostName];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [AppDel setupStream];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    
    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = network_Info.subscriberCellularProvider;
    
    NSLog(@"country code is: %@", carrier.mobileCountryCode);
   
    signUpButton.layer.cornerRadius=3;
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    [self loadSignInWithFacebook];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [UtilitiesHelper changeTextFields:emailTextField];
    [UtilitiesHelper changeTextFields:passwordTextField];
    [UtilitiesHelper changeTextFields:confirmPasswordTextField];
    [UtilitiesHelper changeTextFields:numberTextField];
    [UtilitiesHelper changeTextFields:firstNameTextField];
    firstNameTextField.autocapitalizationType=UITextAutocapitalizationTypeSentences;

}

//- (NSString *)getCountryCode {
//    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
//    CTCarrier *carrier = network_Info.subscriberCellularProvider;
//    
//    NSLog(@"country code is: %@", carrier.mobileCountryCode);
//    
//    NSString *code = code
//}



- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];

    _facebookInformationLoaded = FALSE;
    
    CGRect newFrame;;
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    if (iOSDeviceScreenSize.height > 500)
    {
        newFrame = CGRectMake(20, 380, 280, 43);
    }
    else {
        newFrame = CGRectMake(20, 350, 280, 43);
    }
    loginview.frame = newFrame;
    
    CGRect newButtonFrame = CGRectMake(0, 0, 280, 43);
    [[loginview.subviews objectAtIndex:0] setFrame:newButtonFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark Facebook Methods--------------



- (void)loadSignInWithFacebook {
    loginview = [UtilitiesHelper loadFacbookButton:CGRectMake(20, 380, 280, 43)];
    loginview.delegate = self;
    [self.view addSubview:loginview];
    
    NSLog(@"Array : %@",loginview.subviews);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
//    self.profilePictureView.profileID = [user objectForKey:@"id"];
//    NSLog(@"Profile View : %@",self.profilePictureView.subviews);
//
//    UIImage *image = [[self.profilePictureView.subviews objectAtIndex:0] image];

    if (!_facebookInformationLoaded) {
//        [self signUpUsingFacebookAccount:user image:nil];
    }
}

- (void)signUpUsingFacebookAccount:(id<FBGraphUser>)user image:(UIImage *)image {
    _facebookInformationLoaded = TRUE;
    FacebookSignUpViewController *facebookSignUpView = [self.storyboard instantiateViewControllerWithIdentifier:@"facebookSignUpView"];
    facebookSignUpView.userInformation = user;
//    facebookSignUpView.userImage = image;
    NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
    [navigationArray removeObjectAtIndex:1];
    [navigationArray addObject:facebookSignUpView];
    [self.navigationController setViewControllers:navigationArray];
//    double delayInSeconds = 0.5;
//    NSLog(@"User data from facebook %@",user);
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//         });
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"You're logged in");
    
       [[loginview.subviews objectAtIndex:2] setText:@"Log Out From Facebook"];
   
   
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"You're logged out");
    [[loginview.subviews objectAtIndex:2] setText:@"Connect with facebook"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signUpButtonClicked:(UIButton *)sender {
    if (!firstNameTextField.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter your first name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self checkEmailAndDisplayAlert];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[emailTextField text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        if (numberTextField.text.length > 0) {
            if ([self validatePhoneNumber:numberTextField.text]) {
                [self checkPassword];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid number of 10 digit." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid number of 10 digit." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)checkPassword {
    if (!passwordTextField.text.length > 0 || !confirmPasswordTextField.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password cannot be blank." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if (![passwordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password mismatch" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"If you entered in your number incorrectly without verifying, you could miss out on some important notifications. Do you want to verify your number?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Skip",@"Ya Sure!", nil];
        NSRange range=[emailTextField.text  rangeOfString:@"@"];
        NSString *userName=[[emailTextField.text  substringToIndex:range.location] lowercaseString];
        
        [[NSUserDefaults standardUserDefaults]setValue:userName forKey:@"user_name"];
        [[NSUserDefaults standardUserDefaults]setValue:[[NSString stringWithFormat:@"%@",confirmPasswordTextField.text] lowercaseString] forKey:@"user_password"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Skip"]) {
        [self setUserDataDictionaryForVerification:[NSNumber numberWithBool:FALSE]];
    }
    else if ([title isEqualToString:@"Ya Sure!"]) {
        [self setUserDataDictionaryForVerification:[NSNumber numberWithBool:TRUE]];
    }
    
}

- (void)setUserDataDictionaryForVerification:(NSNumber *)toVerify {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              firstNameTextField.text,@"firstName",
                              emailTextField.text, @"email",
                              passwordTextField.text, @"password",
                              numberTextField.text, @"mobile",
                              @"hoothere",@"signupType",
                              @"ios",@"platform",
                              toVerify,@"toVerify",
                              oldTokenId,@"deviceId",
                              nil];
    [self sendApiRequestForSignUp:userData];
}

- (void)sendApiRequestForSignUp:(NSDictionary *)userData {
    _xmppStream.hostPort = 5222;
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream setHostName:kHostName];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [AppDel setupStream];
    
    [self connect];
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/register",kwebUrl];
    
    [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
            
             NSString *userId=[jsonDict objectForKey:@"id"];
             if(userId) {
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                 
                 if(![[userData objectForKey:@"toVerify"] boolValue])
                 {
                 
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setBool:YES forKey:@"isloggedin"];
                     [defaults synchronize];
                     [CoreDataInterface saveUserInformation:jsonDict];
                     
//                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                     [alertView show];
                     
                     HootHereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"hootHereView"];
                     NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                     [navigationArray removeObjectAtIndex:1];
                     [navigationArray addObject:whoThereView];
                     [self.navigationController setViewControllers:navigationArray];
                 }
                 else {
                    VerifyViewController *verifyView = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyView"];
                     verifyView.userId=[jsonDict objectForKey:@"id"];
                     verifyView.phoneNumber=[jsonDict objectForKey:@"mobile"];
                     [self.navigationController pushViewController:verifyView animated:YES];
                 }
             }
         }
     }];
}

-(BOOL)validateEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)validatePhoneNumber:(NSString *)phoneNumber {
    BOOL valid;
//    if (phoneNumber.length == 10) {
//        return NO;
//    }
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:phoneNumber];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    if (!valid) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark Textfield Delegate -------

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == numberTextField) {
        if (numberTextField.text.length != 10) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        [_numberCheckAnimator startAnimating];
        self.view.userInteractionEnabled = NO;
        _numberCheckAnimator.hidden = NO;
        NSString *urlString = [NSString stringWithFormat:@"%@/user/isMobileAvailable/%@",kwebUrl,numberTextField.text];
        
        [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             self.view.userInteractionEnabled = YES;

             [_numberCheckAnimator stopAnimating];
             _numberCheckAnimator.hidden = YES;
             if (success) {
                 BOOL isMobileAvailable = [[jsonDict objectForKey:@"isMobileAvailable"] boolValue];
                 
                 if (!isMobileAvailable) {
                     
                     [numberTextField becomeFirstResponder];
                     numberTextField.text = @"";
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This number is already link with another user." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                 }
             }
         }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField==firstNameTextField)
        [emailTextField becomeFirstResponder];
    else if (textField == emailTextField) {
        [numberTextField becomeFirstResponder];
    }
    else if (textField == numberTextField) {
        [passwordTextField becomeFirstResponder];
    }
    else if (textField == passwordTextField) {
        [confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == confirmPasswordTextField) {
        [self signUpButtonClicked:signUpButton];
    }
    return YES;
}

#pragma mark Country Code Delegate --------


-(IBAction)actionMethodSelectCountry:(id)sender{
    CountryListViewController *pupulateCountryList = [[CountryListViewController alloc]initWithNibName:@"CountryListViewController" bundle:nil];
    //pupulateCountryList.parentScreen = self;
    pupulateCountryList.delegate = self;
    
    [self.navigationController pushViewController:pupulateCountryList animated:NO];
}

-(void) countryListReturnedValues:(NSString *)countryName andCode:(NSString *)countryCode{
    [countryCodeButton setTitle:[NSString stringWithFormat:@"+%@", countryCode] forState:UIControlStateNormal];
}


#pragma Mark XMPP method Declration  //     7-April-2015, Unoiatech.

- (BOOL)connect {
    
    self.xmppStream.hostName = kHostName;
    NSString *jabberID =[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"],kDomainName];
    NSLog(@"Jabbar ID is %@",jabberID);
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_password"];
    self.xmppStream.enableBackgroundingOnSocket=FALSE;
    if (![self.xmppStream isDisconnected]) {
        
        NSLog(@"connected XMPP");
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
       NSLog(@"connected to server ");
    [self goOnline];
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
        NSLog(@"self.xmppStream isDisconnected");
        [self connect];
    }
    
    if ([self.xmppStream isConnecting]){
        NSLog(@"self.xmppStream isConnecting");
    }
    
    if ([self.xmppStream isConnected]){
        
               NSLog(@"Is Connected");
           UIAlertView *showAlert=[[UIAlertView alloc]initWithTitle:@"Connected XMPP" message:@"Connected successfull" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
 //            [showAlert show];
        
    }
    
    NSError *error = nil;
    [[self xmppStream]registerWithPassword:self.password error:nil];
    /*  if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
     
     {
     
     //   NSLog(@"Error authenticating: %@", error);
     
     } */
   
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration with XMPP Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
  //  [alert show];
  //  [self goOnline];
    [AppDel goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration with XMPP   Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if([errorCode isEqualToString:@"409"]){
        
        [alert setMessage:@"Username Already Exists!"];
    }
    [alert show];
}

-(void)goOnline{
    
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    [AppDel discoverRoom];
}

@end
