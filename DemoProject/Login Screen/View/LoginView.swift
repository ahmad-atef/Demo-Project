//
//  ContentView.swift
//  DemoProject
//
//  Created by Ahmad Atef on 11/12/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color.gray.secondary)
                .cornerRadius(8.0)
            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .padding()
                .background(Color.gray.secondary)
                .cornerRadius(8.0)
            
            Button("Login") {
                viewModel.performLogin()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange.gradient)
            .cornerRadius(8.0)
            .bold()
        }
        .padding()
        
        if let emailErrorMessage = viewModel.emailErrorMessage {
            Text(emailErrorMessage)
                .font(.footnote)
                .foregroundColor(.red)
        }
        
        if let passwordErrorMessage = viewModel.passwordErrorMessage {
            Text(passwordErrorMessage)
                .font(.footnote)
                .foregroundColor(.blue)
        }
        
        if let user = viewModel.user {
            Text("Welcome: \(user.name)")
                .font(.title)
                .background(Color.green)
        }
        
        if let errorMessage = viewModel.errorMessage {
            Text("Error: \(errorMessage)")
                .foregroundColor(.red)
        }
        
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(loginService: MockLoginService()))
}
