//
//  URLRequestConfiguration.swift
//  DemoProject
//
//  Created by Ahmad Atef on 12/12/2024.
//

import Foundation

struct URLRequestConfiguration {
    let baseURL: URL
    let pathComponents: String
    let httpMethod: String
    let headers: [String: String]
    let requestBody: [String: String]
}
