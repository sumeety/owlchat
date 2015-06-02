//
//  FacebookSignUpViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 19/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "FacebookSignUpViewController.h"
#import "UtilitiesHelper.h"
#import "HomeViewController.h"
#import "CoreDataInterface.h"
#import "VerifyViewController.h"
#import "WhoThereViewController.h"

@interface FacebookSignUpViewController ()

@end

@implementation FacebookSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _numberCheckAnimator.hidden = YES;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    proceedButton.layer.cornerRadius=3;
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    // Do any additional setup after loading the view.
    NSLog(@"In Facebook  Sign Up view Controller");
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    [self loadUSerInformationFromFacebook];
    [UtilitiesHelper changeTextFields:userEmailfield];
    [UtilitiesHelper changeTextFields:userNumberTextfield];
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)loadUSerInformationFromFacebook {
    self.profilePictureView.profileID = _userInformation.objectID;
    [self provideRoundCornerFor:self.profilePictureView cornerRadius:34];
    userImageView.image = _userImage;
    
    userNameLabel.text = [_userInformation objectForKey:@"name"];
    userEmailLabel.text = [_userInformation objectForKey:@"email"];
    userDOBLabel.text = [_userInformation objectForKey:@"birthday"];
    userEmailfield.text = [_userInformation objectForKey:@"email"];
    NSLog(@"userinfo in facebook %@",[_userInformation objectForKey:@"id"]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)provideRoundCornerFor:(FBProfilePictureView *)profileImageView cornerRadius:(CGFloat)cornerRadius {
    
    profileImageView.layer.cornerRadius = 34;
    profileImageView.layer.masksToBounds = YES;
}

- (IBAction)signUpButtonClicked:(UIButton *)sender {
    [self checkEmailAndDisplayAlert];
}

- (void)checkEmailAndDisplayAlert {
    if(![self validateEmail:[userEmailfield text]]) {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self checkPassword];
}
-(void) checkPassword{
//    if (!passwordTextField.text.length > 0 || !confirmPasswordTextField.text.length > 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password cannot be blank." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//    }
//    else if (![passwordTextField.text isEqualToString:confirmPasswordTextField.text]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password mismatch" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//    }
//    else {
        if (userNumberTextfield.text.length == 10) {
            if ([self validatePhoneNumber:userNumberTextfield.text]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"If you entered in your number incorrectly without verifying, you could miss out on some important notifications. Do you want to verify your number?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Skip",@"Ya Sure!", nil];
                [alertView show];
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid 10 digit number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid 10 digit number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
//    }
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
                              userEmailfield.text, @"email",
                              //                                          passwordTextField.text, @"password",
                              userNumberTextfield.text, @"mobile",
                              @"F",@"signupType",
                              ([_userInformation objectForKey:@"id"])?[_userInformation objectForKey:@"id"]:@" ",@"facebookId",
                              ([_userInformation objectForKey:@"first_name"])?[_userInformation objectForKey:@"first_name"]:@" ",@"firstName",
                              
                              ([_userInformation objectForKey:@"last_name"])?[_userInformation objectForKey:@"last_name"]:@" ",@"lastName",
                              ([_userInformation objectForKey:@"birthday"])?[_userInformation objectForKey:@"birthday"]:@" ",@"dateOfBirth",
                              @"ios",@"platform",
                              toVerify,@"toVerify",
                              oldTokenId,@"deviceId",
                              nil];
    [self sendApiRequestForSignUp:userData];
}

- (void)sendApiRequestForSignUp:(NSDictionary *)userData {
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    NSLog(@"userData %@",userData);
    NSString *urlString = [NSString stringWithFormat:@"%@/user/register",kwebUrl];
    
    [UtilitiesHelper getResponseFor:userData url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             NSString *userId=[jsonDict objectForKey:@"id"];
             if(userId) {
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Your password has been emailed on this id" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alertView show];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                 for (UIImageView *imageView in _profilePictureView.subviews) {
                     if ([imageView isKindOfClass:[UIImageView class]]) {
                         _userImage = [imageView image];
                     }
                 }
                 NSData *imageData = UIImagePNGRepresentation(_userImage);
                 [UtilitiesHelper uploadImage:imageData];
                 [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(userImageView.image) forKey:@"UserImage"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [UtilitiesHelper getFacebookFriends];

                 if(![[userData objectForKey:@"toVerify"] boolValue])
                 {
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setBool:YES forKey:@"isloggedin"];
                     [defaults synchronize];
                     [CoreDataInterface saveUserInformation:jsonDict];
                     
                     WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
                     NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                     if (navigationArray.count > 2) {
                         [navigationArray removeObjectAtIndex:1];
                     }
                     [navigationArray removeObjectAtIndex:1];
                     [navigationArray addObject:whoThereView];
                     [self.navigationController setViewControllers:navigationArray];
                 }
                 else {
                     VerifyViewController *verifyView = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyView"];
                     verifyView.userId=[jsonDict objectForKey:@"id"];
                     verifyView.phoneNumber=[jsonDict objectForKey:@"mobile"];
                     //                                 [self.navigationController pushViewController:verifyView animated:YES];
                     NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
                     [navigationArray removeObjectAtIndex:1];
                     [navigationArray addObject:verifyView];
                     [self.navigationController setViewControllers:navigationArray];
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

#pragma mark Country Code Delegate --------

#pragma mark Textfield Delegate -------

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == userNumberTextfield) {
        if (userNumberTextfield.text.length != 10) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        [_numberCheckAnimator startAnimating];
        self.view.userInteractionEnabled = NO;
        _numberCheckAnimator.hidden = NO;
        NSString *urlString = [NSString stringWithFormat:@"%@/user/isMobileAvailable/%@",kwebUrl,userNumberTextfield.text];
        
        [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             self.view.userInteractionEnabled = YES;
             
             [_numberCheckAnimator stopAnimating];
             _numberCheckAnimator.hidden = YES;
             if (success) {
                 BOOL isMobileAvailable = [[jsonDict objectForKey:@"isMobileAvailable"] boolValue];
                 
                 if (!isMobileAvailable) {
                     
                     [userNumberTextfield becomeFirstResponder];
                     userNumberTextfield.text = @"";
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This number is already link with another user." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alertView show];
                 }
             }
         }];
    }
}

-(IBAction)actionMethodSelectCountry:(id)sender{
    CountryListViewController *pupulateCountryList = [[CountryListViewController alloc]initWithNibName:@"CountryListViewController" bundle:nil];
    //pupulateCountryList.parentScreen = self;
    pupulateCountryList.delegate = self;
    
    [self.navigationController pushViewController:pupulateCountryList animated:NO];
}

-(void) countryListReturnedValues:(NSString *)countryName andCode:(NSString *)countryCode{
    [countryCodeButton setTitle:[NSString stringWithFormat:@"+%@", countryCode] forState:UIControlStateNormal];
}

@end
