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
            let viewModel = LoginViewModel()
            LoginView(viewModel: viewModel)
        }
    }
}
