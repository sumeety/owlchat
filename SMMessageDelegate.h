//
//  SMMessageDelegate.h
//  jabberClient
//
//  Created by cesarerocchi on 8/2/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Utils.h"

@protocol SMMessageDelegate

- (void)newMessageReceived:(NSMutableDictionary *)messageContent;
-(void)groupMessageReceived:(NSMutableDictionary *)messageReceived;
@end
