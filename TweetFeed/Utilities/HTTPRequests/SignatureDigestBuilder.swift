//
//  SignatureDigestBuilder.swift
//  TweetFeed
//
//  Created by Abhay Curam on 4/13/18.
//  Copyright © 2018 Tweeter. All rights reserved.
//

import Foundation
import UIKit

public struct SignatureDigestBuilder {
    
    public static func signatureDigest(for request: URLRequest, oauthParams: [String : String]) -> String? {
        var signatureParameters = [(String, String)]()
        guard let url = request.url else { return nil }
        if let queryString = url.query, queryString != "" {
            signatureParameters += SignatureDigestBuilder.rawQueryParams(from: queryString)
        }
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8), bodyString != "" {
            signatureParameters += SignatureDigestBuilder.rawQueryParams(from: bodyString)
        }
        signatureParameters += SignatureDigestBuilder.rawOauthParams(from: oauthParams)
        let encodedSignatureParameters = signatureParameters.map { signatureParam in
            return (signatureParam.0.rfc3986PercentEncoding() ?? "", signatureParam.1.rfc3986PercentEncoding() ?? "")
        }
        
        let sortedSignatureParams = encodedSignatureParameters.sorted { $0.0 < $1.0 }
        let signatureParamsStr = SignatureDigestBuilder.stringFromSignatureParams(sortedSignatureParams)
        guard let httpMethod = request.httpMethod else { return nil }
        let signatureBaseString = SignatureDigestBuilder.signatureBaseString(from: signatureParamsStr, url: url, httpMethod: httpMethod)
        let credentials = TweetFeedUserCredentials()
        let signingKey = "\(credentials.clientSecret().rfc3986PercentEncoding() ?? "")&\(credentials.accessTokenSecret().rfc3986PercentEncoding() ?? "")"
        return HmacSHA1Signer.sign(signatureBaseString, forKey: signingKey)
    }
    
    private static func signatureBaseString(from signatureParamsString: String, url: URL, httpMethod: String) -> String {
        var signatureBaseString = ""
        signatureBaseString += httpMethod.uppercased()
        signatureBaseString += "&"
        signatureBaseString += url.urlStringByTrimmingQuery()?.removingPercentEncoding?.rfc3986PercentEncoding() ?? ""
        signatureBaseString += "&"
        signatureBaseString += signatureParamsString.rfc3986PercentEncoding() ?? ""
        return signatureBaseString
    }
    
    private static func rawQueryParams(from string: String) -> [(String, String)] {
        var params = [(String, String)]()
        let queryString = string
        let queryParameters = queryString.components(separatedBy: "&")
        for queryParameter in queryParameters {
            let queryPair = queryParameter.components(separatedBy: "=")
            let queryKey = queryPair.first?.removingPercentEncoding ?? ""
            let queryValue = queryPair.last?.removingPercentEncoding ?? ""
            params.append((queryKey, queryValue))
        }
        
        return params
    }
    
    private static func rawOauthParams(from oauthParams: [String : String]) -> [(String, String)] {
        var params = [(String, String)]()
        for (paramKey, paramValue) in oauthParams {
            let paramKey = paramKey.removingPercentEncoding ?? ""
            let paramValue = paramValue.removingPercentEncoding ?? ""
            params.append((paramKey, paramValue))
        }
        
        return params
    }
    
    private static func stringFromSignatureParams(_ params: [(String, String)]) -> String {
        var buffer = ""
        for signatureParam in params {
            buffer += "\(signatureParam.0)=\(signatureParam.1)&"
        }
        return String(buffer.dropLast())
    }
}
