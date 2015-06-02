//
//  GroupChatViewController.h
//  Hoothere
//
//  Created by UnoiaTech on 02/04/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "XMPPStream.h"
#import "XMPPRoster.h"
#import "XMPP.h"
#import "GroupChatTableViewCell.h"
#import "XMPPRosterCoreDataStorage.h"
#import "TURNSocket.h"
#import "XEP_0223.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "XMPPRoomMessageMemoryStorageObject.h"
#import "XMPPRoomMessageHybridCoreDataStorageObject.h"
#import "XMPPRoomOccupantCoreDataStorageObject.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPReconnect.h"
#import <CoreData/CoreData.h>
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP_0333.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPIQ+XEP_0066.h"
#import "XMPPIQ+XEP_0060.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPRoomCoreDataStorage.h"
#import "SMMessageDelegate.h"
@interface GroupChatViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,TURNSocketDelegate,XMPPStreamDelegate,XMPPRosterDelegate,NSFetchedResultsControllerDelegate,SMMessageDelegate> {
    XMPPReconnect *xmppReconnect;
    XMPPMessageArchiving *xmppMessageArchivingModule;
}
@property (nonatomic,strong) NSString *groupName;
@property (strong, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
@property (strong, nonatomic) UITextField *messageTextField;
@property (strong,nonatomic) UIBarButtonItem * sendMessageBttn;
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;

@property (strong,nonatomic) XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;
@property (strong,nonatomic) XMPPStream *xmppStream;
@property (strong,nonatomic) XMPPRoster *xmppRoster;
@property (strong,nonatomic) XMPPRosterCoreDataStorage *xmppRosterStorage;
-(void) setupStream;
-(BOOL)connect;
-(void)goOnline;
- (void)loadChatHistoryWithUserName:(NSString *)userName;
@property (strong,nonatomic)XMPPRoom *xmppRoom ;
-(void)groupMessageReceived:(NSMutableDictionary *)messageReceived;
-(void) reloadChat;
@property (strong,nonatomic) NSString *fromView;
@end
