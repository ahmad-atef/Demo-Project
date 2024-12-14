//
//  LoginService.swift
//  DemoProject
//
//  Created by Ahmad Atef on 11/12/2024.
//

import Foundation



protocol LoginService {
    func loginWith(_ email: String, _ password: String, completionHandler: @escaping (User) -> ())
    func loginWith(_ email: String, _ password: String) async throws -> User
}

final class RemoteLoginService: LoginService {
    private let url: URL
    private let client: LoginClient
    private let urlRequestBuilder: URLRequestBuilder
    
    init(
        url: URL = .login,
        client: LoginClient = RemoteLoginClient.default,
        urlRequestBuilder: URLRequestBuilder = RemoteURLRequestBuilder()
    ) {
        self.url = url
        self.client = client
        self.urlRequestBuilder = urlRequestBuilder
    }

    func loginWith(_ email: String, _ password: String, completionHandler: @escaping (User) -> ()) {
        let urlRequest = buildURLRequestWith(url: url, email: email, password: password)

        client.execute(request: urlRequest) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let success):
                print("Success: \(success)")
            case .failure(let failure):
                print("failure: \(failure)")
            }
        }
    }
    
    func loginWith(_ email: String, _ password: String) async throws -> User {
        let urlRequest = buildURLRequestWith(url: url, email: email, password: password)
        
        do {
            let (_, _) = try await client.execute(request: urlRequest)
            // Mock response data
            let mockResponseData = provideMockUserDataResponse()
            if let user = try? JSONDecoder().decode(User.self, from: mockResponseData) {
                return user
            } else {
                throw LoginServiceError.invalidData
            }
            
        } catch {
            throw error
        }
    }
    
    
    
    private func buildURLRequestWith(url: URL, email: String, password: String) -> URLRequest {
        let configuration = URLRequestConfiguration(
            baseURL: url,
            pathComponents: "/posts",
            httpMethod: "POST",
            headers: ["Content-Type":"application/json"],
            requestBody: ["email": email, "password": password]
        )
        
        return urlRequestBuilder.buildWith(configuration: configuration)
    }
    
    private func provideMockUserDataResponse() -> Data {
        """
        {
            "id": 101,
            "name": "John Doe",
            "email": "example@example.com",
            "token": "abcdef123456"
        }
        """.data(using: .utf8)!
    }
}

enum LoginServiceError: Error {
    case invalidData
    case connectivity
}

private extension URL {
    static let login = URL(string: "https://jsonplaceholder.typicode.com")!
}
