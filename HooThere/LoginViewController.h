//
//  LoginViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "XMPPFramework.h"
#import "XMPP.h"
#import "XMPPStream.h"
#import "XMPPRoster.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate,XMPPStreamDelegate,XMPPRosterDelegate> {
    IBOutlet UITextField        *emailTextfield;
    IBOutlet UITextField        *passwordTextfield;
    FBLoginView                 *loginview;
    IBOutlet UIButton           *loginButton;
    XMPPStream                  *xmppStream;
    XMPPRoster                  *xmppRoster;
}

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic)         BOOL      facebookInformationLoaded;

@property (strong,nonatomic) XMPPStream *xmppStream;
@property (strong,nonatomic) NSString   *password;
- (IBAction)loginButtonClicked:(UIButton *)sender;
-(BOOL)connect;

@end
