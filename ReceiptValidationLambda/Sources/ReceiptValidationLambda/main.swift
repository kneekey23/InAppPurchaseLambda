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
    print(body)
    do {
        let receiptInput = try decoder.decode(Input.self, from: body)
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer { try? httpClient.syncShutdown() }
        let secret = getEnvVariable(name: "APPSECRET")
        let appStoreClient = AppStore.Client(httpClient: httpClient, secret: secret)
        let receipt = try appStoreClient.validateReceipt(receiptInput.receipt).wait()
        print(receipt)
        let output = Output(isValid: true)
        let encoder = JSONEncoder()
        let encodedOutput = try! encoder.encode(output)
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
