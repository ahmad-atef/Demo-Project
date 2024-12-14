//
//  MockLoginService.swift
//  DemoProject
//
//  Created by Ahmad Atef on 12/12/2024.
//

import Foundation

final class MockLoginService: LoginService {
    func loginWith(
        _ email: String,
        _ password: String,
        completionHandler: @escaping (User) -> ()
    ) {
        preconditionFailure("Not yet implemented!")
    }

    func loginWith(_ email: String, _ password: String) async throws -> User {
        let mockData = """
        {
            "id": 906,
            "name": "Abdallah Jad",
            "email": "ahmad.atef@gmail.com",
            "token": "902123"
        }
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(User.self, from: mockData)
        return user
    }

    
}
