import AWSLambdaRuntime
import AppStoreReceiptValidation

struct Input: Codable {
    //base 64 encoded string containing app store receipt
    let receipt: String
}

struct Output: Codable {
    //should return whether or not the receipt is valid
    let isValid: Bool
}

Lambda.run { (context, input: Input, callback: @escaping (Result<Output, Error>) -> Void) in
    let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    defer { try? httpClient.syncShutdown() }

    let appStoreClient = AppStore.Client(httpClient: httpClient, secret: "abc123")

    let base64EncodedReceipt: String = ...
    let receipt = try appStoreClient.validateReceipt(base64EncodedReceipt).wait()
    callback(.success(Output(isValid: false)))
}
