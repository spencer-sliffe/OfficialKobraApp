//
//  KobraApp.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/15/23.
//

import SwiftUI
import Firebase

@main
struct KobraApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            let viewModel = SignUpViewModel(authApi: AuthService.shared, authServiceParser: AuthServiceParser.shared)
            SignUpView(viewModel: viewModel)
        }
    }
}
