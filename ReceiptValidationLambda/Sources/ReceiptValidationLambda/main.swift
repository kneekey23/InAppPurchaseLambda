import AWSLambdaRuntime
import AWSLambdaEvents
import Foundation
import AsyncHTTPClient
//import AppStoreReceiptValidation

struct Input: Codable {
    //base 64 encoded string containing app store receipt
    let receipt: String
}

struct Output: Codable {
    //should return whether or not the receipt is valid
    let isValid: Bool
}

Lambda.run { (context, input: APIGateway.Request, callback: @escaping (Result<APIGateway.Response, Error>) -> Void) in
    let decoder = JSONDecoder()
    //decode the receipt from the body of the api gateway request
    guard let body = input.body else {
        //if there is nothing in the body of the request return a bad request status code
        callback(.success(APIGateway.Response(statusCode: .badRequest)))
        return
    }
    //body is a base 64 encoded string so need to decode first before decoding from json
    let decodedData = Data(base64Encoded: body)!
    let decodedString = String(data: decodedData, encoding: .utf8)!
    print(decodedString)
    let receiptInput = try! decoder.decode(Input.self, from: decodedString)
    let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    defer { try? httpClient.syncShutdown() }
//
//    let appStoreClient = AppStore.Client(httpClient: httpClient, secret: "abc123")
//    let receipt = try appStoreClient.validateReceipt(receiptInput.receipt).wait()
    let output = Output(isValid: true)
    let encoder = JSONEncoder()
    let encodedOutput = try! encoder.encode(output)
    let encodedOutputString = String(decoding: encodedOutput, as: UTF8.self)
    let response = APIGateway.Response(statusCode: .ok, body: encodedOutputString)
    callback(.success(response))
}
