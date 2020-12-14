//
//  Receipt.swift
//  InAppPurchaseApp
//
//  Created by Stone, Nicki on 12/10/20.
//
import Foundation

class ReceiptManager {
    static let receiptAPIURL = "https://kfolhojv16.execute-api.us-west-2.amazonaws.com/Prod/validate"
    
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
    
    static public func loadAndValidateReceipt(completion: @escaping (Bool) -> Void) {
        guard let receipt = loadReceipt() else {
            completion(false)
            return
        }
        
        let receiptObject = Receipt(receipt: receipt)
        let encoder = JSONEncoder()
        let encodedReceipt = try! encoder.encode(receiptObject)
        var receiptIsValid = false
        //call to swift lambda to validate receipt
        let url = URL(string: ReceiptManager.receiptAPIURL)!
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue("application-json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encodedReceipt
        request.httpMethod = "POST"
        print(request)
        let task = urlSession.dataTask(with: request) { (data, urlResponse, error) in
            if let data = data, error == nil {
            let decoder = JSONDecoder()
                do {
                    let output = try decoder.decode(Output.self, from: data)
                    print(output)
                    receiptIsValid = output.isValid
                    completion(receiptIsValid)
                }
                catch let err {
                    print(err)
                    completion(receiptIsValid)
                }
            }
        }
        task.resume()
        
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

struct Output: Codable {
    //should return whether or not the receipt is valid
    let isValid: Bool
}
