//
//  AppDelegate.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "GeofenceMonitor.h"
#import "XMPPFramework.h"
#import "XMPPRoster.h"
#import "XMPPStream.h"
#import "XMPPReconnect.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPSASLAuthentication.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPMessageArchiving.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessage+XEP_0333.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPMUC.h"
#import "XMPPRoomOccupantCoreDataStorageObject.h"
#import "XMPPRoomMessageCoreDataStorageObject.h"
#import "XMPPRoomMessageMemoryStorageObject.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoomHybridStorage.h"
#import "SMMessageDelegate.h"
#import "SingleUserChatViewController.h"
#import "SMChatDelegate.h"
#define AppDel (AppDelegate *)[[UIApplication sharedApplication] delegate]

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate,XMPPRosterDelegate,XMPPStreamDelegate,XMPPRoomDelegate,XMPPMUCDelegate,XMPPRoomMemoryStorageDelegate>
{
    BOOL isXmppConnected;
    BOOL customCertEvaluation;
    BOOL isOpen;
    NSMutableArray *turnSockets;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPAnonymousAuthentication *auth;
    XMPPMessageArchiving *xmppMessageArchivingModule;
    __weak NSObject <SMChatDelegate> *_chatDelegate;
   // __weak NSObject <SMMessageDelegate> *_messageDelegate;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) CLLocationManager   *locationManager;

@property (nonatomic,strong)GeofenceMonitor *geofenceMonitor;


@property (strong, nonatomic)NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic)NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong,nonatomic) NSString *password;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic,strong) XMPPRoster *xmppRoster;
@property (strong,nonatomic) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (strong,nonatomic) XMPPMessageArchiving *xmppMessageArchivingModule;
@property (nonatomic,strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic,strong) XMPPRoomMemoryStorage *xmppRoomMemoryStorage;
@property (nonatomic,strong) XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
-(void) goOnline;
- (BOOL)connect;
-(void)setupStream;
- (void)disconnect;
- (void)teardownStream;
- (void)goOffline;
@property (nonatomic,strong) XMPPRoom *xmppRoom;
@property (nonatomic,strong)  XMPPMUC * xmppMUC;
-(void)sendDefaultRoomConfig:(NSString *)room;
- (void)createChatRoom:(NSString *) newRoomName;
-(void)leaveGroup;
@property (strong,nonatomic) NSString *toSomeone;
@property (nonatomic, assign) id<SMMessageDelegate> messageDelegate;
@property (nonatomic,strong) NSMutableArray *roomList;
@property (nonatomic,strong) NSMutableArray *memberList;
-(void)discoverRoom;
- (void) joinMultiUserChatRoom:(NSString *) newRoomName;
@end
