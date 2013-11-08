//
//  CHFClientManager.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/31/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFClientManager.h"

#import <ANKUser.h>

NSString * const kClientDictionaryKey = @"clientDictionary";

@interface CHFClientManager ()

@property (nonatomic, strong) NSDictionary *clientDictionary;
@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation CHFClientManager

+ (instancetype)sharedClientManager
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.defaults = [NSUserDefaults standardUserDefaults];
        
        NSData *dictionaryData = [self.defaults objectForKey:kClientDictionaryKey];
        
        if (dictionaryData)
        {
            self.clientDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
        }
        else
        {
            self.clientDictionary = @{};
        }
    }
    
    return self;
}

#pragma mark - Client Management

- (void)addClient:(ANKClient *)client
{
    // Add the client to the dictionary
    NSMutableDictionary *clientDict = [self.clientDictionary mutableCopy];
    
    [clientDict setObject:client forKey:[NSString stringWithFormat:@"%@", client.authenticatedUser.userID]];
    
    self.clientDictionary = [clientDict copy];
    
    [self save];
}

- (void)removeClient:(ANKClient *)client
{
    NSMutableDictionary *clientDict = [self.clientDictionary mutableCopy];
    
    [clientDict removeObjectForKey:[NSString stringWithFormat:@"%@", client.authenticatedUser.userID]];
    
    self.clientDictionary = [clientDict copy];
    
    [self save];
}

- (void)save
{
    // Get the dictionary ready to be saved to the userDefaults
    NSData *clientsDictionaryData = [NSKeyedArchiver archivedDataWithRootObject:self.clientDictionary];
    
    // Save the dictionary
    [self.defaults setObject:clientsDictionaryData forKey:kClientDictionaryKey];
}

#pragma mark - Helpers

- (ANKClient *)currentClient
{
    for (NSString *key in self.clientDictionary)
    {
        return self.clientDictionary[[NSString stringWithFormat:@"%@", key]];
    }
    
    return nil;
}

- (BOOL)currentClientIsAuthenticated
{
    return NO;
}

- (ANKClient *)clientObjectForUser:(ANKUser *)user
{
    __block ANKClient *clientObject;
    
    [self.clientDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, ANKClient *client, BOOL *stop) {
        if (client.authenticatedUser)
        {
            if ([key isEqualToString:user.userID])
            {
                clientObject = client;
            };
        }
    }];
    
    return clientObject;
}

- (NSArray *)allAuthenticatedClients
{
    NSMutableArray *array = [@[] mutableCopy];
    
    [self.clientDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, ANKClient *client, BOOL *stop) {
        if (client.authenticatedUser)
        {
            [array addObject:client];
        }
    }];
    
     return [array copy];
}

- (NSArray *)allEnabledClients
{
    NSMutableArray *array = [@[] mutableCopy];
    
    for (ANKClient *client in [self allAuthenticatedClients])
    {
        if (client) // TODO: check if client is enabled
        {
            [array addObject:client];
        }
    }
    
    return [array copy];
}

#pragma mark - Debugging Methods

- (void)printClientKeys
{
    for (id key in self.clientDictionary)
    {
        NSLog(@"key: %@, value: %@ \n", key, [self.clientDictionary objectForKey:key]);
    }
}

@end
