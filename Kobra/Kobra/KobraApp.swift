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
    typealias imagePackageTuple = (image: UIImage, package: Package)
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
