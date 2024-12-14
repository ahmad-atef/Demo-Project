//
//  LoginClient.swift
//  DemoProject
//
//  Created by Ahmad Atef on 11/12/2024.
//

import Foundation

typealias LoginClientResponse = (Data, HTTPURLResponse)

protocol LoginClient {
    func execute(request: URLRequest, completion: @escaping (Result<(LoginClientResponse), Error> ) -> Void)
    func execute (request: URLRequest) async throws -> LoginClientResponse
}

enum RemoteClientError: Error {
    case unExpectedResponse
}


/// Remote Client for login the username and password via calling the end point
final class RemoteLoginClient: LoginClient {
    
    static let `default` = RemoteLoginClient()
    
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Old fusion technique where we are using completion handlers
    func execute(request: URLRequest, completion: @escaping (Result<LoginClientResponse, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                completion(.success(LoginClientResponse(data, response)))
            } else {
                completion(.failure(RemoteClientError.unExpectedResponse))
            }
        }.resume()
    }
    
    // Modern technique where we are using async / await
    func execute(request: URLRequest) async throws -> LoginClientResponse {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            throw RemoteClientError.unExpectedResponse
        }
        return (data, response)
    }
}
