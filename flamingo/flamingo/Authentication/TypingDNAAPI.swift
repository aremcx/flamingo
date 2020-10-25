//
//  TypingDNAAPI.swift
//  flamingo
//
//  Created by Răzvan-Gabriel Geangu on 20/10/2020.
//

import Foundation

// MARK: - Credentials

let kApiKey = "ce1475182ff875a47811ff880e6ee886"
let kApiSecret = "dbd2ea1f330a50493fac3031e17a2055"
let kApiAuthentication = "Basic \("\(kApiKey):\(kApiSecret)".data(using: .utf8)!.base64EncodedString())"

class TypingDNAAPI: NSObject {
    static let shared = TypingDNAAPI()
    
    // MARK: - Setup
    
    private func initRequest(_ route: String) -> URLRequest {
        /// Set up request defaults
        var request = URLRequest(url: URL(string: "https://api.typingdna.com\(route)")!)
        request.httpMethod = "POST"
        request.setValue(kApiAuthentication, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    // MARK: - Methods
    
    /// [Save typing pattern](https://api.typingdna.com/#api-API_Services-saveUserPattern) takes a typing pattern generated by the recorder as an argument and it uses the API from **TypingDNA** to perform a registrtation.
    /// - Parameter typingPattern: A typing pattern recorded with the **TypingDNA** class.
    /// - Parameter id: An anonymized string of your choice that identifies the user on your end (min `6` char, max `256` char). Please note that this string has to be unique and should not be personal information (email address, name, phone number, etc). If you still want to use something like an email address as ID, we suggest sending a salted hash of it. More about data privacy in our [SLA](https://www.typingdna.com/legal/legal.html).
    func save(typingPattern: String, id: String) {
        var request = initRequest("/save/\(id)")
        
        /// Set up data
        request.httpBody = "tp=\(typingPattern)".data(using: .utf8)
        
        /// Call for response
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                guard let model = try? JSONDecoder().decode(RegisterAPIResponse.self, from: data) else { return }
                print(model.message == "Done")
            }
        }.resume()
    }
    
    /// The [Verify typing pattern](https://api.typingdna.com/#api-API_Services-verifyTypingPattern) takes typingPattern string generated by the recorder as an argument and it uses the API from **TypingDNA** to perform an identification.
    ///  - Parameter typingPattern: A typing pattern recorded with the **TypingDNA** class. For dual pass, submit two typing patterns separated by `;` Dual pass: if the user verification has been rejected the first time, we recommend recording a new typing pattern and send both typing patterns concatenated with ; the second time. This will improve the verification of a user’s identity.
    /// - Parameter id: An anonymized string of your choice that identifies the user on your end (min `6` char, max `256` char). Please note that this string has to be unique and should not be personal information (email address, name, phone number, etc). If you still want to use something like an email address as ID, we suggest sending a salted hash of it. More about data privacy in our [SLA](https://www.typingdna.com/legal/legal.html).
    func verify(typingPattern: String, id: String, didVerify: @escaping (_ model: VerifyAPIResponse) -> Void) {
        var request = initRequest("/verify/\(id)")
        
        /// Set up data
        request.httpBody = "tp=\(typingPattern)&quality=1".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                guard let model = try? JSONDecoder().decode(VerifyAPIResponse.self, from: data) else { return }
                didVerify(model)
            }
        }.resume()
    }
}

// MARK: - Response representations

/// To save/enroll a new user and/or a new typing pattern you have to make the /save request. We recommend to save at least 2 typing patterns per user in order to perform accurate authentications.
struct RegisterAPIResponse: Codable {
    /// Status message, typically `"Done"`.
    var message: String
    
    /// Message [code](https://api.typingdna.com/#api-guidelines-message-codes).
    var message_code: Int
    
    /// Return `1` for success and `0` for failure.
    var success: Int
    
    /// Http status code
    var status: Int
}

///The typical flow ​to​ ​record​ ​a​ ​new​ typing pattern is to issue a request to the Save API,​ followed by subsequent requests to the Verify API (the Auto-Enroll setting can combine these steps, explained in the Guidelines). When sending a pattern for verification it will be compared only to patterns coming from a similar device type (desktop, mobile), and in case of mobile patterns, registered in the same position of the phone.
struct VerifyAPIResponse: Codable {
    /// Status message, typically `Done`.
    var message: String

    /// Message [code](https://api.typingdna.com/#api-guidelines-message-codes).
    var message_code: Int

    /// Return `1` for success and `0` for failure.
    var success: Int
    
    /// Http status code
    var status: Int
    
    /// A value of `0` (false match) or `1` (true match). This is calculated based on a default `net_score` threshold of `50`. If you wish to modify the threshold value, configure the API Settings available in the User Dashboard.
    var result: Int
    
    /// A value from `0` to `100` representing the match value. This value is not adjusted based on the `confidence` value. A number larger than `50` usually means a positive match.
    var score: Int
    
    ///​ A computed statistical value that is typically smaller for longer texts and multiple previous recordings. Larger interval means larger prediction error. The actual predicted value is in an interval: `prediction_interval​ ​= score​ ​±​ ​confidence_interval`
    @available(*, deprecated, renamed: "confidence")
    var confidence_interval: Int

    /// A percentage showing how confident we are in the `score` we return. The confidence is based on parameters such as: the length of the typed text, previous samples, device type, algorithm type, and general typing quality.
    var confidence: Int
    
    /// The `score` adjusted based on confidence. The higher the confidence, the closer the `net_score` value will be to the score value being returned. A low confidence however will decrease the `net_score`. The general formula used is: `net_score = score * confidence%`. You can use `net_score` instead of result and put your own threshold where you need.
    var net_score: Int
    
    /// A value from `0` to `100` representing the device similarity between the ones from which the existing patterns have been registered and the new one.
    var device_similarity: Int
    
    /// An array containing the [mobile typing positions](https://api.typingdna.com/#api-overview-mobile-positions) of the typing patterns sent in the request. Desktop typing patterns will result in an empty array.
    var positions: [Int]

    /// The number of patterns which have actually been matched against, as the samples selected initially are filtered to leave out only the relevant typing patterns. e.g. out of `10`, the user has only `1` pattern on position `3`.
    var compared_samples: Int
    
    /// Returns one of the following values: `enroll`, `verify`, `verify;enroll`. Enroll is returned if the minimum number of enrolled patterns was not yet reached, and Auto-Enroll/Force Initial Enrollments settings are enabled. Verify is returned if [Auto-Enroll](https://api.typingdna.com/index.html#api-guidelines-auto-enroll) is not activated or, when activated, or when activated, if the [Score Threshold for Auto-Enroll](https://api.typingdna.com/index.html#api-guidelines-auto-enroll) was not reached. When [Auto-Enroll](https://api.typingdna.com/index.html#api-guidelines-auto-enroll) is active and the [Score Threshold for Auto-Enroll](https://api.typingdna.com/index.html#api-guidelines-auto-enroll) is reached, the returned value is `verify;enroll`.
    var action: String
    
    /// The number of patterns which have been initially selected for matching, depending on pattern type and device type. e.g. user has `10` mobile patterns.
    var previous_samples: Int
}
