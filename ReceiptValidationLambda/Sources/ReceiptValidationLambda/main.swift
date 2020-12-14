import AWSLambdaRuntime
import AWSLambdaEvents
import Foundation
import AsyncHTTPClient
import AppStoreReceiptValidation

struct Input: Codable {
    //base 64 encoded string containing app store receipt
    let receipt: String
}

struct Output: Codable {
    //should return whether or not the receipt is valid
    let isValid: Bool
}

Lambda.run { (context, input: APIGateway.Request, callback: @escaping (Result<APIGateway.Response, Error>) -> Void) in
    print(input)
    let decoder = JSONDecoder()
    //decode the receipt from the body of the api gateway request
    guard let body = input.body else {
        //if there is nothing in the body of the request return a bad request status code
        callback(.success(APIGateway.Response(statusCode: .badRequest)))
        return
    }
    
    do {
        let receiptInput = try decoder.decode(Input.self, from: body)
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer { try? httpClient.syncShutdown()}
        //if you have a receipt with an auto-renewable subscription you would include an app secret and uncomment the below line
        //let secret = getEnvVariable(name: "APPSECRET")
        let appStoreClient = AppStore.Client(httpClient: httpClient, secret: nil)
        print("app store client created about to make the call")
        let receipt = try appStoreClient.validateReceipt(receiptInput.receipt).wait()
        print("object was returned \(receipt)")
        var isValid = false
        //for subscriptions youll want ot compare expiration dates of a subscription for but for just consumable purchases, i just want to confirm that it has been purchased so that there is something inside the inApp Array.
        if receipt.inApp.count > 1 {
            isValid = true
        }
        let output = Output(isValid: isValid)
        let encoder = JSONEncoder()
        let encodedOutput = try encoder.encode(output)
        let encodedOutputString = String(decoding: encodedOutput, as: UTF8.self)
        let response = APIGateway.Response(statusCode: .ok, body: encodedOutputString)
        callback(.success(response))
    } catch let err {
        print(err)
        callback(.failure(err))
    }
}

func getEnvVariable(name: String) -> String? {
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    return nil
}
