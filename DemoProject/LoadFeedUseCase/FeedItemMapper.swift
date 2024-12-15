//
//  FeedItemMapper.swift
//  DemoProject
//
//  Created by Ahmad Atef on 15/12/2024.
//

import Foundation

final class FeedItemMapper {
    static func map(data: Data, response: HTTPURLResponse) -> FeedLoaderResult {
        
        guard (200..<300).contains(response.statusCode),
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { return .failure(RemoteFeedLoader.Error.invalidData) }
        return .success(root.feedItems)
    }
}

struct Root: Decodable {
    let apiFeedItems: [APIFeedItem]
    var feedItems: [FeedItem] {
        apiFeedItems.map { $0.feedItem }
    }
    
    private enum CodingKeys: String, CodingKey {
        case apiFeedItems = "items"
    }
}

/// DTO: Data Transfer Object representing the
struct APIFeedItem {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var feedItem: FeedItem {
        FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: image
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case image = "url"
    }
}
extension APIFeedItem: Decodable { }
