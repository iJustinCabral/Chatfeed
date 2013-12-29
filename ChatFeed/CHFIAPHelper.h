//
//  IAPHelper.h
//  Daily
//
//  Created by Justin Cabral on 10/23/13.
//
//

@import Foundation;
@import StoreKit;

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);


@interface CHFIAPHelper : NSObject

+ (CHFIAPHelper *)sharedInstance;

- (instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifer;
- (void)restoreCompletedTransactions;


@end
