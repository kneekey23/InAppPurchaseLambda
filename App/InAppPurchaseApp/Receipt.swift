//
//  Receipt.swift
//  InAppPurchaseApp
//
//  Created by Stone, Nicki on 12/10/20.
//
import Foundation

enum ReceiptStatus: String {
  case validationSuccess = "This receipt is valid."
  case noReceiptPresent = "A receipt was not found on this device."
  case unknownFailure = "An unexpected failure occurred during verification."
  case unknownReceiptFormat = "The receipt is not in PKCS7 format."
  case invalidPKCS7Signature = "Invalid PKCS7 Signature."
  case invalidPKCS7Type = "Invalid PKCS7 Type."
  case invalidAppleRootCertificate = "Public Apple root certificate not found."
  case failedAppleSignature = "Receipt not signed by Apple."
  case unexpectedASN1Type = "Unexpected ASN1 Type."
  case missingComponent = "Expected component was not found."
  case invalidBundleIdentifier = "Receipt bundle identifier does not match application bundle identifier."
  case invalidVersionIdentifier = "Receipt version identifier does not match application version."
  case invalidHash = "Receipt failed hash check."
  case invalidExpired = "Receipt has expired."
}

class Receipt {
  var receiptStatus: ReceiptStatus?
  var bundleIdString: String?
  var bundleVersionString: String?
  var bundleIdData: Data?
  var hashData: Data?
  var opaqueData: Data?
  var expirationDate: Date?
  var receiptCreationDate: Date?
  var originalAppVersion: String?
  var inAppReceipts: [IAPReceipt] = []

  static public func isReceiptPresent() -> Bool {
    if let receiptUrl = Bundle.main.appStoreReceiptURL,
      let canReach = try? receiptUrl.checkResourceIsReachable(),
      canReach {
        return true
    }

    return false
  }
    
    init() {
    }
    
    static public func loadAndValidateReceipt() -> Bool {
        let receipt = loadReceipt()
        
        //call to swift lambda to validate receipt
        
        return false //invalid receipt
    }
    
    static private func loadReceipt() -> String? {
        // Get the receipt if it's available
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
           
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)

                let receiptString = receiptData.base64EncodedString(options: [])

                return receiptString
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                return nil
                
            }
        }
        return nil
    }
    
}
