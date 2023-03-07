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
    @StateObject var dataManager = DataManager()
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
