//
//  CHFClientManager.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/31/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ANKClient.h>

#define ClientManager \
((CHFClientManager *)[CHFClientManager sharedClientManager])

@interface CHFClientManager : NSObject

+ (instancetype)sharedClientManager;

- (void)addClient:(ANKClient *)client;
- (void)removeClient:(ANKClient *)client;

- (ANKClient *)currentClient;
- (BOOL)currentClientIsAuthenticated;

- (ANKClient *)clientObjectForUser:(ANKUser *)user;

- (NSArray *)allAuthenticatedClients;
- (NSArray *)allEnabledClients; // Will check what authenticated clients are enabled



@end
