//
//  RemoteFeedLoaderTests.swift
//  DemoProjectTests
//
//  Created by Ahmad Atef on 14/12/2024.
//

import XCTest
import DemoProject

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestUpOnCreation() {
        // given
        let (_, client) = makeSUT()
        
        // then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromInjectedURL() {
        // given
        let url = URL.given
        let (sut, client) = makeSUT()
        
        // when
        sut.load { _ in }
        
        // then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_shouldInvokeRequestTwice() {
        let url = URL.given
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // given
        let (sut, client) = makeSUT()
        var capturedResult: FeedLoaderResult?
        
        // when
        sut.load { result in
            capturedResult = result
        }

        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        // then
        XCTAssertEqual(capturedResult, .failure(.connectivity))
    }
    
    func test_load_deliversErrorOnNon200StatusCodeResponse() {
        // given
        let (sut, client) = makeSUT()
        var expectedResult: FeedLoaderResult?

        // when
        sut.load { result in
            expectedResult = result
        }
        client.complete(withStatusCode: 300)
        
        // then
        XCTAssertEqual(expectedResult, .failure(.invalidData))
        
    }
    
    // MARK: Helper
    private func makeSUT(url: URL = .given) -> (RemoteFeedLoader, SpyClient) {
        let client = SpyClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        return (loader, client)
    }
    
    private class SpyClient: HTTPClient {
        typealias Completion = ((Result<(Data, HTTPURLResponse), Error>) -> Void)
        var messages: [(url: URL, completion: Completion)] = []
        var requestedURLs: [URL?] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping Completion) {
            messages.append((url: url, completion: completion))
        }

        func complete(with error: NSError, at index: Int = 0) {
            // completions[0] ==>> .completion(.
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let httpURLResponse = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((Data(), httpURLResponse)))
        }
    }
}

private extension URL {
    static let given = URL(string: "http://a-given-url.com")!
}
