//
//  HTTPClient.swift
//  DemoProject
//
//  Created by Ahmad Atef on 14/12/2024.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
