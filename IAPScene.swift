//
//  IAPScene.swift
//  MineralScavenger
//
//  Created by Yanbing Peng on 24/03/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation
import StoreKit

class IAPScene : CCNode, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    //MARK: -outlets
    var _storeList : CCNode!
    var _popupNode : CCNode!
    var _popupLine1 : CCLabelTTF!
    var _popupLine2 : CCLabelTTF!
    var _background1Sprite : CCSprite!
    var _background2Sprite : CCSprite!
    
    var _warnningNode :CCNode!
    
    //MARK: -variables
    let STORE_ITEM_IDENTIFIERS = [CONSTANTS.STORE_ITEM_IDENTIFIER1]
    var productIds : Set<String> = Set<String>()
    
    var productsArray:[SKProduct] = [SKProduct]()
    
    var backgroundSize = CGSizeZero
    
    var purchaseItemIndex = -1
    
    //MARK; -life Cycle
    func didLoadFromCCB(){
        for identifier in STORE_ITEM_IDENTIFIERS{
            productIds.insert(identifier.getAssociatedString())
        }
    }
    
    override func onEnter() {
        super.onEnter()
        _popupNode.visible = false
        _warnningNode.visible = false
        backgroundSize = _background1Sprite.convertContentSizeToPoints(_background1Sprite.contentSize, type: _background1Sprite.contentSizeType)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductInfo()
        
    }
    
    override func update(delta: CCTime) {
        loopBackground(delta)
    }
    
    //MARK: -target Actions
    func closeButtonPressed(){
        let mainScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(mainScene)
    }
    
    
    
    //MARK: -private func
    func requestProductInfo(){
        if !SKPaymentQueue.canMakePayments(){
            _warnningNode.visible = true
        }
        let productRequest = SKProductsRequest(productIdentifiers: productIds)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func createStoreItems(){
        print("[CreateStoreItems]")
        let canMakePayments = SKPaymentQueue.canMakePayments()
        _storeList.removeChildByName("StoreItem")
        var itemPositionYOffSet:CGFloat = 30
        for i in 0 ..< productsArray.count{
            let product  = productsArray[i]
            if let storeItem = CCBReader.load("Sprites/StoreItem") as? StoreItem{
                storeItem._itemTitle.string = product.localizedTitle
                storeItem._itemDescription.string = "$\(product.price.floatValue) [" + product.localizedDescription + "]"
                
                storeItem.positionType = CCPositionType.init(xUnit: CCPositionUnit.Points, yUnit: CCPositionUnit.Points, corner: CCPositionReferenceCorner.TopLeft)
                storeItem.position = CGPointMake(0, itemPositionYOffSet)
                storeItem.name = "StoreItem"
                storeItem._buyButton.name = "\(i)"
                storeItem._buyButton.setTarget(self, selector: #selector(IAPScene.buyButtonPressed(_:)))
                
                if let _userDefaults = NSUserDefaults.standardUserDefaults().objectForKey(CONSTANTS.NSUSER_DEFAULT_KEY) as? [String:AnyObject]{
                    if let purchased = _userDefaults[product.productIdentifier] as? Bool{
                        if purchased{
                            storeItem._buyButton.enabled = false
                            storeItem._buyButton.visible = false
                            storeItem._itemDescription.string = "Purchased"
                        }
                    }
                }
                
                if !canMakePayments{
                    storeItem._buyButton.enabled = false
                    storeItem._buyButton.visible = false
                    storeItem._itemDescription.string = "Not Available"
                }
                _storeList.addChild(storeItem)
                itemPositionYOffSet += 80
            }
        }
    }
    
    func buyButtonPressed(button:CCButton){
        //print("[buyButtonPressed]")
        if let index  = Int.init(button.name){
            //print("\(index)")
            _popupNode.visible = true
            _popupNode.name = button.name
            _popupLine2.string = productsArray[index].localizedTitle
        }
    }
    
    func purchaseButtonPressed(){
        _popupNode.visible = false
        
        if let index = Int.init(_popupNode.name){
            let payment  = SKPayment(product: productsArray[index])
            SKPaymentQueue.defaultQueue().addPayment(payment)
            purchaseItemIndex = index
        }
    }
    
    func restorePurchaseButtonPressed(){
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func cancelButtonPressed(){
        _popupNode.visible = false
    }
    
    func refreshButtonPressed(){
        _warnningNode.visible = false
        let productRequest = SKProductsRequest(productIdentifiers: productIds)
        productRequest.delegate = self
        productRequest.start()
    }
    
    //MARK: -private func
    private func loopBackground(delta:CCTime){
        var bk1Position = _background1Sprite.convertPositionToPoints(_background1Sprite.positionInPoints, type: _background1Sprite.positionType)
        var bk2Position = _background2Sprite.convertPositionToPoints(_background2Sprite.positionInPoints, type: _background2Sprite.positionType)
        
        bk1Position = CGPointMake((bk1Position.x - CGFloat(delta) * 10 ), 0)
        bk2Position = CGPointMake((bk2Position.x - CGFloat(delta) * 10 ), 0)
        if bk1Position.x < -backgroundSize.width{
            bk1Position.x = backgroundSize.width
        }
        if bk2Position.x < -backgroundSize.width{
            bk2Position.x = backgroundSize.width
        }
        
        _background1Sprite.position = bk1Position
        _background2Sprite.position = bk2Position
    }
    
    //MARK: -delegate [SKProductsRequestDelegate]
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0{
            for product in response.products{
                productsArray.append(product)
            }
            createStoreItems()
        }
        else{
            _warnningNode.visible = true
        }
        
        if response.invalidProductIdentifiers.count != 0{
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        _warnningNode.visible = true
    }
    /*
    - (void)request:(SKRequest *)request didFailWithError:(NSError *)error
    {
    alert = [[UIAlertView alloc] initWithTitle:@"In-App Store unavailable" message:@"The In-App Store is currently unavailable, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    }*/

    //MARK: -delegate [SKPaymentTransactionObserver]
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Restored:
                guard let productIdentifier = transaction.originalTransaction?.payment.productIdentifier else {return}
                print("[RestoreTransaction]: \(productIdentifier)")
                transactionSuccessHandler(productIdentifier)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Purchased:
                print("Transaction completed successfully")
                transactionSuccessHandler(transaction.payment.productIdentifier)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed")
                transactionFailedHandler(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                print(transaction.transactionState.rawValue)
                break
            }
        }
    }
    
    private func transactionSuccessHandler(identifier:String?){
        guard let identifier = identifier else {return}
        
        var userDefaults = [String:AnyObject]()
        if let _userDefaults = NSUserDefaults.standardUserDefaults().objectForKey(CONSTANTS.NSUSER_DEFAULT_KEY) as? [String:AnyObject]{
            userDefaults = _userDefaults
        }
        userDefaults[identifier] = true
        NSUserDefaults.standardUserDefaults().setObject(userDefaults, forKey: CONSTANTS.NSUSER_DEFAULT_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func transactionFailedHandler(transaction: SKPaymentTransaction){
        if transaction.error?.code != SKErrorCode.PaymentCancelled.rawValue{
            UIAlertView.init(title: "Transaction Error", message: "\(transaction.error?.localizedDescription)", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
}

















