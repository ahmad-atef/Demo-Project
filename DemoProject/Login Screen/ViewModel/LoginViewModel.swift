//
//  LoginViewModel.swift
//  DemoProject
//
//  Created by Ahmad Atef on 12/12/2024.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {

    @Published var email: String = "" {
        didSet {
            validate(
                field: email,
                using: EmailValidator.shared,
                updating: &emailErrorMessage
            )
        }
    }
    @Published var emailErrorMessage: String?
    
    @Published var password: String = "" {
        didSet {
            validate(
                field: password,
                using: PasswordValidator.shared,
                updating: &passwordErrorMessage
            )
        }
    }
    @Published var passwordErrorMessage: String?

    @Published var user: User?
    @Published var errorMessage: String?
    
    
    private let loginService: LoginService
    
    init(loginService: LoginService = RemoteLoginService()) {
        self.loginService = loginService
    }
    
    func performLogin() {
        Task { @MainActor in
            do {
                user = try await loginService.loginWith(email, password)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func validate(field: String, using validator: InputValidator, updating errorMessage: inout String?) {
        switch validator.validate(input: field) {
        case .valid:
            errorMessage = nil
        case .invalid(let validationError):
            errorMessage = validationError.rawValue
        }
    }
}

enum ValidationStatus {
    enum ValidationError: String {
        case empty
        case notEmailFormat
        case passwordNotStrongEnough
    }
    case valid
    case invalid(ValidationError)
}

protocol InputValidator {
    func validate(input: String) -> ValidationStatus
}

final class EmailValidator: InputValidator {
    static let shared = EmailValidator()
    func validate(input: String) -> ValidationStatus {
        guard !input.isEmpty else { return .invalid(.empty) }
        if isValidEmail(input) {
            return .valid
        } else {
            return .invalid(.notEmailFormat)
        }
        
    }
    private func isValidEmail(_ input: String) -> Bool {
        let emailRegEx = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let emailPred = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailPred.evaluate(with: input)
    }
}

final class PasswordValidator: InputValidator {
    static let shared = PasswordValidator()
    func validate(input: String) -> ValidationStatus {
        guard !input.isEmpty else { return .invalid(.empty) }
        guard input.count > 5 else { return .invalid(.passwordNotStrongEnough) }
        return .valid
    }
}
