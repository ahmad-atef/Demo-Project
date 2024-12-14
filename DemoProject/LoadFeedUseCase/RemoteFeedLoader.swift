//
//  FeedLoader.swift
//  DemoProject
//
//  Created by Ahmad Atef on 14/12/2024.
//

import Foundation

public typealias FeedLoaderResult = Result<FeedItem, RemoteFeedLoader.Error>

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}


public final class RemoteFeedLoader: FeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (FeedLoaderResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(.connectivity))
            case .success((let data, let response)):
                completion(.failure(.invalidData))
            }
        }
    }
}
