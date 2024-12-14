//
//  FeedLoader.swift
//  DemoProject
//
//  Created by Ahmad Atef on 14/12/2024.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (Result<FeedItem, Error>) -> Void)
}
