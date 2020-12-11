//
//  IAPReceipt.swift
//  InAppPurchaseApp
//
//  Created by Stone, Nicki on 12/10/20.
//

import Foundation

struct IAPReceipt {
  var quantity: Int?
  var productIdentifier: String?
  var transactionIdentifer: String?
  var originalTransactionIdentifier: String?
  var purchaseDate: Date?
  var originalPurchaseDate: Date?
  var subscriptionExpirationDate: Date?
  var subscriptionIntroductoryPricePeriod: Int?
  var subscriptionCancellationDate: Date?
  var webOrderLineId: Int?
}
