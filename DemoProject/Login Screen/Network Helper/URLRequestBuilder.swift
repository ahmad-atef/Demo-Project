//
//  URLBuilder.swift
//  DemoProject
//
//  Created by Ahmad Atef on 12/12/2024.
//
import Foundation

protocol URLRequestBuilder {
    func buildWith(configuration: URLRequestConfiguration) -> URLRequest
}

class RemoteURLRequestBuilder: URLRequestBuilder {
    func buildWith(configuration: URLRequestConfiguration) -> URLRequest {
        var request = URLRequest(url: configuration.baseURL.appendingPathComponent(configuration.pathComponents))
        request.httpMethod = configuration.httpMethod
        configuration.headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: configuration.requestBody)
        return request
    }
}
