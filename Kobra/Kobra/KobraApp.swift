//
//  KobraApp.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/15/23.
//

import SwiftUI

@main
struct KobraApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = SignUpViewModel()
            SignUpView(viewModel: viewModel)
        }
    }
}
