//
//  SignUpViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CountryListViewController.h"
#import "XMPPFramework.h"
#import "XMPP.h"
#import "XMPPStream.h"
#import "XMPPRoster.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP_0333.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "TURNSocket.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate, countryListDelegate, UIAlertViewDelegate,XMPPStreamDelegate,XMPPRosterDelegate>{
    
    IBOutlet UITextField        *numberTextField;
    IBOutlet UITextField        *firstNameTextField;
    IBOutlet UITextField        *emailTextField;
    IBOutlet UITextField        *passwordTextField;
    IBOutlet UITextField        *confirmPasswordTextField;
    IBOutlet UIButton           *countryCodeButton;
    

    FBLoginView                 *loginview;

    IBOutlet UIButton *signUpButton;
    XMPPStream                  *xmppStream;
    XMPPRoster                  *xmppRoster;
}

- (IBAction)signUpButtonClicked:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView  *numberCheckAnimator;
@property (strong, nonatomic) UIActivityIndicatorView           *activityIndicator;
@property (nonatomic, strong) id<FBGraphUser>  user;
@property(nonatomic,strong)UIImage *image;

@property (nonatomic)         BOOL      facebookInformationLoaded;
@property (strong,nonatomic) XMPPStream *xmppStream;
@property (strong,nonatomic) NSString   *password;
- (BOOL)connect;
@end
