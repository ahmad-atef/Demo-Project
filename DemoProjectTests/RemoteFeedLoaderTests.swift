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
    
    // Failure scenario - Error course
    func test_load_deliversErrorOnClientError() {
        // given
        let (sut, client) = makeSUT()
        
        expect(
            sut: sut,
            toCompleteWithResult: .failure(.connectivity),
            when: {
                let clientError = NSError(domain: "Test", code: 0)
                client.complete(with: clientError)
            }
        )
    }
    
    func test_load_deliversErrorOnNon200StatusCodeResponse() {
        // given
        let (sut, client) = makeSUT()
        
        expect(
            sut: sut,
            toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: 300)
        }
    }
    
    func test_load_deliversErrorOn200StatusCodeWithInvalidResponse() {
        // given
        let (sut, client) = makeSUT()
        
        expect(
            sut: sut,
            toCompleteWithResult: .failure(.invalidData),
            when: {
                let invalidData = "invalid-json".data(using: .utf8)!
                client.complete(withStatusCode: 200, data: invalidData)
            }
        )
    }
    
    // Success scenario - Primary course
    
    func test_load_deliversEmptyListOn200StatusCodeWithEmptyJSONList() {
        // given
        let (sut, client) = makeSUT()
        
        expect(
            sut: sut,
            toCompleteWithResult: .success([]),
            when: {
                client.complete(withStatusCode: 200, data: .emptyFeedItem)
            }
        )
    }
    
    func test_load_deliversFeedItemsOn200StatusCodeWithValidJSONList() {
        let (sut, client) = makeSUT()
        let feedItems: [FeedItem] = .sampleData
        
        let jsonData = """
        {
            "items": 
            [
                {
                    "id": "\(feedItems[0].id.uuidString)",
                    "description": "\(feedItems[0].description!)",
                    "location": "\(feedItems[0].location!)",
                    "url": "\(feedItems[0].imageURL.absoluteString)",
                },
                {
                    "id": "\(feedItems[1].id.uuidString)",
                    "url": "\(feedItems[1].imageURL.absoluteString)"
                }
            ]
        }
        """.data(using: .utf8)!
        
        expect(
            sut: sut,
            toCompleteWithResult: .success(.sampleData),
            when: {
                client.complete(withStatusCode: 200, data: jsonData)
            }
        )
    }
    
    func test_load_dosNotDeliverResultAfterLoaderHasBeenDeallocated() {
        // given
        let client = SpyClient()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: .given, client: client)
        var capturedResult: RemoteFeedLoaderResult?
        
        // when
        sut?.load { result in
            capturedResult = result
        }
        sut = nil
        client.complete(withStatusCode: 200)
        
        // then
        XCTAssertNil(capturedResult)
    }
    
    // MARK: Helper
    /// Factory method to create the SUT: `RemoteFeedLoader` along with the Testing dependency: `SpyClient`
    private func makeSUT(url: URL = .given, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedLoader, SpyClient) {
        let client = SpyClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Potential memory leaks!. Instance object should be deallocated.",
                file: file,
                line: line
            )
        }
    }
    
    private func expect(
        sut: RemoteFeedLoader,
        toCompleteWithResult expectedResult: RemoteFeedLoaderResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        var capturedResult: RemoteFeedLoaderResult?
        sut.load { result in
            capturedResult = result
        }
        action()
        XCTAssertEqual(
            expectedResult,
            capturedResult,
            file: file,
            line: line
        )
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
        
        func complete(
            withStatusCode code: Int,
            data: Data = .init(),
            at index: Int = 0
        ) {
            let httpURLResponse = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, httpURLResponse)))
        }
    }
}

private extension URL {
    static let given = URL(string: "http://a-given-url.com")!
}

private extension Data {
    static let emptyFeedItem: Data = {
        """
        {
            "items": []
        }
        """.data(using: .utf8)!
    }()
    
    
}

private extension Array where Element == FeedItem {
    static let sampleData: [FeedItem] = [
        FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: .given),
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: .given),
    ]
}

