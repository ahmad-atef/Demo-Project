//
//  DemoProjectApp.swift
//  DemoProject
//
//  Created by Ahmad Atef on 11/12/2024.
//

import SwiftUI

@main
struct DemoProjectApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: LoginViewModel())
        }
    }
}
