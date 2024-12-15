//
//  FeedItemMapper.swift
//  DemoProject
//
//  Created by Ahmad Atef on 15/12/2024.
//

import Foundation

final class FeedItemMapper {
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard (200..<300).contains(response.statusCode) else { throw RemoteFeedLoader.Error.invalidData }
        let root = try JSONDecoder().decode(Root.self, from: data)
        let feedItems = root.items.map { $0.feedItem }
        return feedItems
    }
}

struct Root: Decodable {
    let items: [APIFeedItem]
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
