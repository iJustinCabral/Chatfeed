//
//  IAPHelper.m
//  Daily
//
//  Created by Justin Cabral on 10/23/13.
//
//

#import "CHFIAPHelper.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@import StoreKit;

@interface CHFIAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *_productsRequest;
    
    RequestProductsCompletionHandler _completionHandler;
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

@end

@implementation CHFIAPHelper

+ (CHFIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static CHFIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"chatfeed.chatstack",
                                      @"chatfeed.customization",
                                      @"chatfeed.stickerpack.1",
                                      @"chatfeed.drawing",
                                      @"chatfeed.pro",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


-(instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Itunes Connect product identifiers
        _productIdentifiers = productIdentifiers;
        
        //Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString *productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            
            if (productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            
            else
            {
                NSLog(@"Not Purchased %@", productIdentifier);

            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

-(void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

#pragma mark - SKProductsDelegate Callbacks
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark - SKTransaction Delegate
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

#pragma mark - Buy & Bought & Restored
-(BOOL)productPurchased:(NSString *)productIdentifer
{
    return  [_purchasedProductIdentifiers containsObject:productIdentifer];
}

-(void)buyProduct:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];

}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - Complete, failed, restored

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


@end
