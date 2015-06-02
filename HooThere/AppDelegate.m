//
//  AppDelegate.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPStream.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "TURNSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "ChatViewController.h"
#import <CFNetwork/CFNetwork.h>
#import "XMPPMessage+XEP_0184.h"
#import "XMPPMessageDeliveryReceipts.h"
#import "XMPPMessage+XEP_0333.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPIQ+XEP_0060.h"
#import "XMPPMUC.h"
#import "GroupChatViewController.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegate ()
{
    SingleUserChatViewController *chatViewController;
}

@end

@implementation AppDelegate

@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height > 500)
        {
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            // Instantiate the initial view controller object from the storyboard
            UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
            
            // Instantiate a UIWindow object and initialize it with the screen size of the iOS device
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            
            // Set the initial view controller to be the root view controller of the window object
            //            self.window.rootViewController  = initialViewController;
            [self.window setRootViewController:initialViewController];
            
            // Set the window object to be the key window and show it
            [self.window makeKeyAndVisible];
        }
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
//    NSLog(@"start updating Location");
//    NSArray * monitoredRegions = [self.locationManager.monitoredRegions allObjects];
//    for(CLRegion *region in monitoredRegions) {
//        [self.locationManager stopMonitoringForRegion:region];
//    }
//    
//    [self.locationManager startUpdatingLocation];
//    
//   self.geofenceMonitor = [[GeofenceMonitor alloc] init];
    
//    //self.geofenceMonitor.delegate = self;
//    //self.geofenceMonitor.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    
//    NSLog(@"start updating Location");

    //[self.geofenceMonitor ];
    
    
//    self.locationTracker = [[LocationTracker alloc]init];
//    [self.locationTracker startLocationTracking];
//    
//    //Send the best location to server every 60 seconds
//    //You may adjust the time interval depends on the need of your app.
//    NSTimeInterval time = 60.0;
//    self.locationUpdateTimer =
//    [NSTimer scheduledTimerWithTimeInterval:time
//                                     target:self
//                                   selector:@selector(updateLocation)
//                                   userInfo:nil
//                                    repeats:YES];
//
    
    [FBProfilePictureView class];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        //        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    _xmppStream=[[XMPPStream alloc]init];
    self.xmppStream.hostPort = 5222;
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream setHostName:kHostName];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _xmppRoomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
    _xmppMUC = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [_xmppMUC   activate:_xmppStream];
    [_xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [self setupStream];
    
    _xmppReconnect = [[XMPPReconnect alloc]init];
    [_xmppReconnect activate:self.xmppStream];

   
    _xmppMessageArchivingCoreDataStorage=[XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMessageArchivingModule=[[ XMPPMessageArchiving alloc]initWithMessageArchivingStorage:[XMPPMessageArchivingCoreDataStorage sharedInstance]];
    _xmppRoomCoreDataStorage =[XMPPRoomCoreDataStorage sharedInstance];
    [_xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [_xmppMessageArchivingModule activate:[self xmppStream]];
    [_xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [self goOnline];
    
    chatViewController=[[SingleUserChatViewController alloc]initWithNibName:@"SingleUserChatViewController" bundle:nil];
    _roomList=[[NSMutableArray alloc]init];
    _memberList=[[NSMutableArray alloc]init];
    
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    UIDevice *device = [UIDevice currentDevice];

    [[NSUserDefaults standardUserDefaults] setObject:[[device identifierForVendor]UUIDString] forKey:@"device_id"];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString* newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    NSLog(@"My token is: %@", newToken);
    
    if (![newToken isEqualToString:oldTokenId]) {
        NSUserDefaults *localDefaults = [NSUserDefaults standardUserDefaults];
        [localDefaults setValue:newToken forKey:@"kPushNotificationUDID"];
        
        [localDefaults synchronize];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received");
    
    if (application.applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushNotificationReceivedForeground" object:userInfo];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushNotificationReceivedBackground" object:userInfo];
    }
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"Received");
//}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //nslog(@"Failed to get token, error: %@", error);
    NSLog(@"Failed to get token, error: %@", error);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
    DDLogError(@"The iPhone simulator does not process background network traffic. "
               @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
    {
        [application setKeepAliveTimeout:600 handler:^{
            
            DDLogVerbose(@"KeepAliveHandler");
            
            // Do other keep alive stuff here.
        }];
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
      DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self connect];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self teardownStream];
}



#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    NSLog(@"Location: %f, %f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    if (currentLocation != nil) {
        [self.locationManager stopUpdatingLocation];
        //[self.locationManager requestAlwaysAuthorization];
    }
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    // Complete url to our database file
    NSString *databaseFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"HooThere.sqlite"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:databaseFilePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"HooThere" ofType:@"sqlite"];
        
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:databaseFilePath error:NULL];
            //}
        }
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: databaseFilePath];
    
    
    
    NSError *error;
    
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *migrateOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:migrateOptions error:&error]) {
        // Handle error
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark App Call Back From Other App

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
    //    return [FBSession.activeSession handleOpenURL:url];
    
}

# pragma mark XMPPFramework Integration
#pragma mark Private
- (void)teardownStream
{
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    
    [_xmppReconnect         deactivate];
    [_xmppRoster            deactivate];
    [_xmppvCardTempModule   deactivate];
    [_xmppvCardAvatarModule deactivate];
    [_xmppCapabilities      deactivate];
    
    [_xmppStream disconnect];
    
    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    _xmppvCardTempModule = nil;
    _xmppvCardAvatarModule = nil;
    _xmppCapabilities = nil;
    _xmppCapabilitiesStorage = nil;
}


- (void)setupStream
{
    // Specify your server's IP address
    [_xmppStream setHostName:kHostName];
    
    // Specify your host port
    [_xmppStream setHostPort:5222];
    self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
    
    self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.xmppRoster activate:_xmppStream];
}

- (BOOL)connect {
    
    self.xmppStream.hostName = kHostName;
    NSString *jabberID =[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"],kDomainName];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_password"];
    self.xmppStream.enableBackgroundingOnSocket=FALSE;

    if (![self.xmppStream isDisconnected]) {
        
   //     NSLog(@"connected XMPP");
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
    //   NSLog(@"connected to server ");
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
        //   NSLog(@"Is DisConnected");
        [self connect];
    }
    
    if ([self.xmppStream isConnecting]){
        //  NSLog(@"Is Connecting");
    }
    
    if ([self.xmppStream isConnected]){
        //          NSLog(@"Is Connected");
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
    // NSLog(@"User Authenticated");
        [self goOnline];
  /*  NSXMLElement *iq1 = [NSXMLElement elementWithName:@"iq"];
    [iq1 addAttributeWithName:@"type" stringValue:@"get"];
    [iq1 addAttributeWithName:@"id" stringValue:@"conference.127.0.0.1"];
    NSXMLElement *retrieve = [NSXMLElement elementWithName:@"list" xmlns:@"urn:xmpp:archive"];
    [retrieve addAttributeWithName:@"with" stringValue:@"richard@127.0.0.1"];
    NSXMLElement *set = [NSXMLElement elementWithName:@"set" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *max = [NSXMLElement elementWithName:@"max" stringValue:@"700"];
    [iq1 addChild:retrieve];
    [retrieve addChild:set];
    
    
    [set addChild:max];
    
    NSLog(@"IQ IS %@",iq1);
    [_xmppStream sendElement:iq1]; */
    
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
    [self discoverRoom];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (void)disconnect {
    
    [self goOffline];
    [_xmppStream disconnect];
//    [_chatDelegate didDisconnect];
}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
   // DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq description]);
  //  NSLog(@"iq description %@",[iq description]);
  /*  NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    if (queryElement)
    {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        for (int i=0; i<[itemElements count]; i++)
        {
            NSLog(@"Friend : %@",[[itemElements[i] attributeForName:@"jid"]stringValue]);
            
        }
    }
    
    NSXMLElement *queryElement = [iq elementForName:@"query" xmlns: @"jabber:iq:roster"];
    NSArray *rosterItems = [queryElement elementsForName: @"item"];
    NSLog(@"Roster items are %@",rosterItems);
    for (NSXMLElement *item in rosterItems) {
        [XMPPUserCoreDataStorageObject insertInManagedObjectContext:[self managedObjectContext_roster] withItem:item streamBareJidStr:@"NewIser"];
    } */
    DDXMLElement *si = [iq elementForName:@"si"];
    NSString *queryXmlns = [iq elementForName:@"query"].xmlns;
    NSString *iqID = [iq elementID];
    
    if(si){
        if([iq.type isEqualToString:@"set"]){
            DDXMLElement *newIQ = [XMPPIQ iqWithType:@"result" to:iq.from elementID:iq.elementID];
            
            DDXMLElement *si = [XMPPElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
            [newIQ addChild:si];
            
            DDXMLElement *feature = [XMPPElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
            [si addChild:feature];
            
            DDXMLElement *x = [XMPPElement elementWithName:@"x" xmlns:@"jabber:x:data"];
            [x addAttributeWithName:@"type" stringValue:@"submit"];
            [feature addChild:x];
            
            DDXMLElement *field = [DDXMLElement elementWithName:@"field"];
            [field addAttributeWithName:@"var" stringValue:@"stream-method"];
            [x addChild:field];
            [field addChild:[DDXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/bytestreams"]];
            
            [_xmppStream sendElement:newIQ];
        }else if([iq.type isEqualToString:@"result"]){
            TURNSocket *turn = [[TURNSocket alloc] initWithStream:_xmppStream toJID:iq.from];
            [turn startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        }
        
        return YES;
    }else if([queryXmlns isEqualToString:@"http://jabber.org/protocol/bytestreams"] && [iq.type isEqualToString:@"set"]){
        TURNSocket *turn = [[TURNSocket alloc] initWithStream:_xmppStream incomingTURNRequest:iq];
        [turn startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        return YES;
    }else if([iqID isEqualToString:@"fkj23erkfd"]){
        DDXMLElement *query = [iq childElement];
        NSMutableArray *rooms = [NSMutableArray array];
        for(DDXMLElement *el in [query elementsForName:@"item"]){
            NSString *jid = [el attributeStringValueForName:@"jid"];
            NSString *name = [el attributeStringValueForName:@"name"];
            [rooms addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:jid, @"jid", name, @"name", nil]];
        }
        
        _roomList=rooms;
        return YES;
    }
    else if([iqID isEqualToString:@"member4567list"]){
        DDXMLElement *query = [iq childElement];
        NSMutableArray *roomMembers = [NSMutableArray array];
        for(DDXMLElement *el in [query elementsForName:@"item"]){
            NSString *jid = [el attributeStringValueForName:@"jid"];
          //  NSString *name = [el attributeStringValueForName:@"name"];

            if (jid == nil || jid == (id)[NSNull null]) {
                
            }
            else {
                NSRange range=[jid rangeOfString:@"@"];
                NSString *name=[jid substringToIndex:range.location];
            [roomMembers addObject:name];
            }
        }
        _memberList=roomMembers;
        return YES;
    }
    return NO;
}
-(void)discoverRoom{
    DDXMLElement *iq = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:@"conference.127.0.0.1"] elementID:@"fkj23erkfd"];
    [iq addChild:[DDXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"]];
    [_xmppStream sendElement:iq];
  //  NSLog(@"IQ SENT IS %@",iq);
    
}

-(void)discoverMemberList
{
//   NSString *fetchID = [[self xmppStream] generateUUID];
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",_xmppStream.myJID]];
    [item addAttributeWithName:@"affiliation" stringValue:@"member"];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
    [query addChild:item];
    
    XMPPIQ *iqRoom = [XMPPIQ iqWithType:@"get" to:[self xmppRoom].roomJID elementID:@"member4567list" child:query];
    
  //  NSLog(@"roomJID %@",iqRoom);
    [_xmppStream sendElement:iqRoom];

}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {

 NSString *type = [[message  attributeForName:@"type"] stringValue];
    if ([type isEqualToString:@"groupchat"]) {
        
        NSString *msg = [[message elementForName:@"body"] stringValue];
        NSString *from = [[message attributeForName:@"from"] stringValue];

        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"msg"];
        [m setObject:from forKey:@"sender"];
        [_messageDelegate groupMessageReceived:m];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Ok";
        localNotification.alertBody =[NSString stringWithFormat:@"From: %@\n\n%@ ",from,msg];
                                      [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    else {
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
    [_messageDelegate newMessageReceived:m];
    }
}


- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    NSMutableDictionary *mutableDict;
    if (![presenceFromUser isEqualToString:myUsername]) {
        
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser,kDomainName]];
            [_messageDelegate newMessageReceived:mutableDict];
            
        }
        else if ([presenceType isEqualToString:@"unavailable"]) {
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser,kDomainName]];
            [chatViewController newMessageReceived:mutableDict];
            [_messageDelegate newMessageReceived:mutableDict];
          //  [chatVC sendPushNotfication];
        }
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:_xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}
- (void)createChatRoom:(NSString *) newRoomName
{
    /**
     * Remember to add 'conference' in your JID like this:
     * e.g. uniqueRoomJID@conference.yourserverdomain
     */
    NSString *groupName = [NSString stringWithFormat:@"%@@%@",newRoomName,kGroupChatDomain];
  /*  XMPPJID *roomJID = [XMPPJID jidWithString:groupName];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[AppDel xmppRoomMemoryStorage]
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    [_xmppRoom activate:[self xmppStream]];
    [[self xmppStream] addDelegate:self
                     delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom addDelegate:self
            delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom joinRoomUsingNickname:[self xmppStream].myJID.user
                            history:nil
                           password:nil];
    */
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:[XMPPJID jidWithString:groupName]];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom activate:_xmppStream];
    DDXMLElement *history = [DDXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"20"];
    [_xmppRoom joinRoomUsingNickname:_xmppStream.myJID.user history:history];
    NSLog(@"createChatRoom");
}

-(void)leaveGroup {
    [_xmppRoom deactivate];
    [_xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidCreate");
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
   NSLog(@"xmppRoomDidJoin");
    [sender fetchMembersList];
    [sender fetchConfigurationForm];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
     //   NSLog(@"didFetchConfigurationForm");
    NSXMLElement *newConfig = [configForm copy];
    //  NSLog(@"BEFORE Config for the room %@",newConfig);
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    //   NSLog(@"AFTER Config for the room %@",newConfig);
    [sender configureRoomUsingOptions:newConfig];
    NSLog(@"didFetchConfigurationForm");
}

-(void)sendDefaultRoomConfig:(NSString *)room
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *presence=[XMPPPresence presence];
     [presence addAttributeWithName:@"to" stringValue:room];
    [presence addAttributeWithName:@"from" stringValue:_xmppStream.myJID.user];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    [x addChild:presence];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/muc#member"];
    [query addChild:x];
    XMPPIQ *iq = [XMPPIQ iq];
    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"inroom-cr%@", room]];
    [iq addAttributeWithName:@"to" stringValue:room];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addChild:query];
   
    [[self xmppStream ] sendElement:iq];
}

/*
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message
{
      NSLog(@"invite in NSXMLElement is %@",roomJID);
    NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    NSXMLElement * invite  = [x elementForName:@"invite"];
  
    NSString * conferenceRoomJID = [[message attributeForName:@"from"] stringValue];
    [self joinMultiUserChatRoom:conferenceRoomJID];

 //   NSString *groupName = [NSString stringWithFormat:@"%@@%@",roomJID,kGroupChatDomain];
   // XMPPJID *roomJIDs = [XMPPJID jidWithString:groupName];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomHybridStorage sharedInstance]
                                                  jid:roomJID
                                        dispatchQueue:dispatch_get_main_queue()];
    
    [_xmppRoom activate:[self xmppStream]];
    [[self xmppStream] addDelegate:self
                     delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom addDelegate:self
             delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom joinRoomUsingNickname:[self xmppStream].myJID.user
                             history:nil
                            password:nil];
   
    [_xmppRoom editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:[XMPPJID jidWithString:_xmppStream.myJID.user]]]];
 //   [self sendDefaultRoomConfig:[NSString stringWithFormat:@"%@",roomJID]];
 //   self.toSomeone = roomJID;
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    [_xmppRoster addUser:roomJID  withNickname:roomJID.full];
    [self goOnline];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Chat Room Invitation" message:@"Invited you to chat room" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];

}
*/

- (void) joinMultiUserChatRoom:(NSString *) newRoomName
{
    _xmppRoomCoreDataStorage=[XMPPRoomCoreDataStorage sharedInstance];
    XMPPJID *roomJID = [XMPPJID jidWithString:newRoomName];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage: _xmppRoomCoreDataStorage
                                                  jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",newRoomName,kGroupChatDomain]]
                                        dispatchQueue:dispatch_get_main_queue()];
    
    [_xmppRoom activate:[self xmppStream]];
      [_xmppRoom joinRoomUsingNickname:_xmppStream.myJID.user history:nil];
//    [self discoverMemberList];
    [_xmppRoom fetchMembersList];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

}

-(void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"Member list is %@",items);
}


-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
 //   NSLog(@"message received from occupant %@",message);
}
-(void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender didReceiveMessage:(XMPPRoomMessageMemoryStorageObject *)message fromOccupant:(XMPPRoomOccupantMemoryStorageObject *)occupant atIndex:(NSUInteger)index inArray:(NSArray *)allMessages{
   /* NSMutableArray *array=[NSMutableArray arrayWithArray:allMessages];
    for (XMPPRoomMessageMemoryStorageObject *message in array) {
       // NSLog(@"messageStr param is %@",message.message);
        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.message.body error:nil];
        //NSLog(@"to param is %@",[element attributeStringValueForName:@"from"]);
        //   NSLog(@"NSCore object id param is %@",message.objectID);
        //NSLog(@"bareJid param is %@",message.jid);
        //NSLog(@"roomJid param is %@",message.roomJID);
        //NSLog(@"body param is %@",message.body);
        //NSLog(@"timestamp param is %@",message.localTimestamp);
        //NSLog(@"outgoing param is %d",message.isFromMe );
        NSString *msg =message.body;
        NSString *from = [element attributeStringValueForName:@"from"];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"msg"];
        [m setObject:from forKey:@"sender"];
              NSLog(@"did receive message called %@",msg);
        [_messageDelegate groupMessageReceived:m];
    } */
}

-(void)getRoomsList {
  /*  NSString* server = @"@conference.127.0.0.1"; //or whatever the server address for muc is
    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[_xmppStream myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [_xmppStream sendElement:iq];
  */
    
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:_xmppStream.myJID.user];
    [iq addAttributeWithName:@"to" stringValue:@"conference.127.0.0.1"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    NSLog(@"IQ IN GET ROOM LIST METHOD %@",iq);
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectContext *)managedObjectContext_roster
{
    
    return [_xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [_xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

#if USE_HYBRID_STORAGE

- (NSArrayController *)arrayController
{
    if (arrayController == nil)
    {
        XMPPRoomHybridStorage *hybridStorage = (XMPPRoomHybridStorage *)xmppRoomStorage;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJIDStr == %@", xmppRoom.roomJID];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:YES];
        
        arrayController = [[NSArrayController alloc] initWithContent:nil];
        arrayController.managedObjectContext = [hybridStorage mainThreadManagedObjectContext];
        arrayController.entityName = hybridStorage.messageEntityName;
        arrayController.fetchPredicate = predicate;
        arrayController.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        //	NSError *error = nil;
        //	if (![arrayController fetchWithRequest:nil merge:NO error:&error])
        //	{
        //		DDLogError(@"arrayController fetch error: %@", error);
        //	}
        
        arrayController.automaticallyPreparesContent = YES;
    }
    
    return arrayController;
}

#endif
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoomMemoryStorage Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if USE_MEMORY_STORAGE

- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
              occupantDidJoin:(XMPPRoomOccupantMemoryStorageObject *)occupant
                      atIndex:(NSUInteger)index
                      inArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    occupants = allOccupants;
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
    
  //  [occupantsTableView beginUpdates];
   //[occupantsTableView insertRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectGap];
   // [occupantsTableView endUpdates];
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
             occupantDidLeave:(XMPPRoomOccupantMemoryStorageObject *)occupant
                      atIndex:(NSUInteger)index
                    fromArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    occupants = allOccupants;
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
    
 //   [occupantsTableView beginUpdates];
   // [occupantsTableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectGap];
    //[occupantsTableView endUpdates];
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
            occupantDidUpdate:(XMPPRoomOccupantMemoryStorageObject *)occupant
                    fromIndex:(NSUInteger)oldIndex
                      toIndex:(NSUInteger)newIndex
                      inArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    occupants = allOccupants;
    
   /* if (oldIndex == newIndex)
    {
        NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:oldIndex];
        NSIndexSet *colIndexes = [NSIndexSet indexSetWithIndex:0];
        
        [occupantsTableView beginUpdates];
        [occupantsTableView reloadDataForRowIndexes:rowIndexes columnIndexes:colIndexes];
        [occupantsTableView endUpdates];
    }
    else
    {
        [occupantsTableView beginUpdates];
        [occupantsTableView moveRowAtIndex:oldIndex toIndex:newIndex];
        [occupantsTableView endUpdates];
    }
     */
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
            didReceiveMessage:(XMPPRoomMessageMemoryStorageObject *)message
                 fromOccupant:(XMPPRoomOccupantMemoryStorageObject *)occupantJID
                      atIndex:(NSUInteger)index
                      inArray:(NSArray *)allMessages {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    messages = allMessages;
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
    
    [messagesTableView beginUpdates];
    [messagesTableView insertRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideUp];
    [messagesTableView endUpdates];
}
#endif
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRoomHybridStorage Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if USE_HYBRID_STORAGE

- (void)xmppRoomHybridStorage:(XMPPRoomHybridStorage *)sender
              occupantDidJoin:(XMPPRoomOccupantHybridMemoryStorageObject *)occupant
{
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:[occupants count]];
    [occupants addObject:occupant];
    
    [occupantsTableView beginUpdates];
    [occupantsTableView insertRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectGap];
    [occupantsTableView endUpdates];
}

- (void)xmppRoomHybridStorage:(XMPPRoomHybridStorage *)sender
             occupantDidLeave:(XMPPRoomOccupantHybridMemoryStorageObject *)occupant
{
    NSUInteger index = [occupants indexOfObject:occupant];
    if (index == NSNotFound) return;
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
    [occupants removeObjectAtIndex:index];
    
    [occupantsTableView beginUpdates];
    [occupantsTableView removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationEffectGap];
    [occupantsTableView endUpdates];
}

- (void)xmppRoomHybridStorage:(XMPPRoomHybridStorage *)sender
            occupantDidUpdate:(XMPPRoomOccupantHybridMemoryStorageObject *)occupant
{
    NSUInteger index = [occupants indexOfObject:occupant];
    if (index == NSNotFound) return;
    
    NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:index];
    NSIndexSet *colIndexes = [NSIndexSet indexSetWithIndex:0];
    
    [occupants replaceObjectAtIndex:index withObject:occupant];
    
    [occupantsTableView beginUpdates];
    [occupantsTableView reloadDataForRowIndexes:rowIndexes columnIndexes:colIndexes];
    [occupantsTableView endUpdates];
}

#endif
@end

