//
//  RemoteFeedLoaderTests.swift
//  DemoProjectTests
//
//  Created by Ahmad Atef on 14/12/2024.
//

import XCTest

final class RemoteFeedLoaderTests: XCTestCase {
    
    class RemoteFeedLoader {
        private let url: URL
        private let client: HTTPClient
        
        init(url: URL, client: HTTPClient) {
            self.url = url
            self.client = client
        }

        func load() {
            client.get(from: url)
        }
    }
    
    protocol HTTPClient {
        func get(from url: URL)
    }
    
    func test_init_doesNotRequestUpOnCreation() {
        // given
        let (client,_) = makeSUT()
        
        // then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromInjectedURL() {
        // given
        let url = URL.given
        let (client,sut) = makeSUT()
        
        // when
        sut.load()
        
        // then
        XCTAssertEqual(url, client.requestedURL)
    }
    
    // MARK: Helper
    private func makeSUT(url: URL = .given) -> (SpyClient, RemoteFeedLoader) {
        let client = SpyClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        return (client, loader)
    }
    
    private class SpyClient: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}

private extension URL {
    static let given = URL(string: "http://a-given-url.com")!
}
