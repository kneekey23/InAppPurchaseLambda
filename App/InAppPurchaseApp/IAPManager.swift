//
//  IAPManager.swift
//  InAppPurchaseApp
//
//  Created by Stone, Nicki on 12/10/20.
//

import StoreKit
import Combine

class IAPManager: NSObject {
    static let shared = IAPManager()
    let purchasePublisher = PassthroughSubject<(String, Bool), Never>()
    var totalRestoredPurchases:Int = 0
    private override init() {
        super.init()
    }
    
    func returnProductIDs() -> Set<String> {
        return ["ReinventHat", "FramedQuote"]
    }
    func getProductsV5() {
        let productIDs = returnProductIDs()
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    func restorePurchasesV5() {
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    func purchaseV5(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
        return true
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                purchasePublisher.send(("Purchased ",true))
            case .restored:
                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)
                purchasePublisher.send(("Restored ",true))
            case .failed:
                if let error = transaction.error as? SKError {
                    purchasePublisher.send(("Payment Error \(error.code) ",false))
                    print("Payment Failed \(error.code)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                print("Ask Mom ...")
                purchasePublisher.send(("Payment Deferred ",false))
            case .purchasing:
                print("working on it...")
                purchasePublisher.send(("Payment in Process ",false))
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            purchasePublisher.send(("IAP: Purchases successfully restored!",true))
        } else {
            purchasePublisher.send(("IAP: No purchases to restore!",true))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                purchasePublisher.send(("IAP Restore Error: " + error.localizedDescription,false))
            } else {
                purchasePublisher.send(("IAP Error: " + error.localizedDescription,false))
            }
        }
    }
}

extension IAPManager: SKProductsRequestDelegate, SKRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let badProducts = response.invalidProductIdentifiers
        let goodProducts = response.products
        if goodProducts.count > 0 {
            productsDB.shared.items = response.products
            print("bon ",productsDB.shared.items)
        }
        print("badProducts ",badProducts)
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("didFailWithError ",error)
        purchasePublisher.send(("Purchase request failed ",true))
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("request did finish")
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
}

final class productsDB: ObservableObject, Identifiable {
    static let shared = productsDB()
    var items:[SKProduct] = []
    {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
}
