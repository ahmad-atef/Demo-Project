//
//  FeedLoader.swift
//  DemoProject
//
//  Created by Ahmad Atef on 14/12/2024.
//

import Foundation

public typealias RemoteFeedLoaderResult = Result<[FeedItem], RemoteFeedLoader.Error>

public protocol FeedLoader {
    func load(completion: @escaping (RemoteFeedLoaderResult) -> Void)
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

    public func load(completion: @escaping (RemoteFeedLoaderResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success((let data, let response)):
                completion(self.map(data: data, response: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoaderResult {
        do {
            let items = try FeedItemMapper.map(data: data, response: response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}
