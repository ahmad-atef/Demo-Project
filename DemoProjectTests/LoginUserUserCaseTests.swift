//
//  LoginUserUserCaseTests.swift
//  DemoProjectTests
//
//  Created by Ahmad Atef on 13/12/2024.
//

import XCTest
@testable import DemoProject

final class LoginUserUserCaseTests: XCTestCase {
    
    func test_init_doesNotRequest() {
        let (_, client) = makeSUT()
        XCTAssertFalse(client.executeCalled, "execute function should NOT being called up on request!")
    }
    
    func testExecutedClientURL() {
        let url = URL(string: "http://example.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loginWith("", "") { _ in }
        
        XCTAssertEqual(client.url, url)
    }
    
    // MARK: Helper Methods
    
    /// Factory method to create SUT (system-under-test) object with configuration.
    private func makeSUT(
        url: URL = URL(string: "https://test.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (RemoteLoginService, SpyClient) {
        let client = SpyClient(url: url)
        let service = RemoteLoginService(url: url, client: client)
        return (service, client)
        
    }
}

private final class SpyClient: LoginClient {
    init(url: URL) {
        self.url = url
    }
    var executeCalled: Bool = false
    let url: URL
    var executedRequest: URLRequest?
    var result: LoginClientResponse?
    var error: Error?
    
    func execute(request: URLRequest) async throws -> LoginClientResponse {
        executeCalled = true
        executedRequest = request
        if let error = error {
            throw error
        }
        return result ?? successResponse()
    }
    
    private func successResponse() -> (Data, HTTPURLResponse) {
        let mockData = """
            {
                "id": 123,
                "name": "mock",
                "email": "mock@gmail.com",
                "token": "T0KeN123",
            }
        """.data(using: .utf8)!
        
        let httpURLResponse = HTTPURLResponse(
            url: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [:]
        )
        
        return (mockData, httpURLResponse!)
    }
    
    func execute(request: URLRequest, completion: @escaping (Result<(LoginClientResponse), any Error>) -> Void) {
        executeCalled = true
        executedRequest = request
    }
}
