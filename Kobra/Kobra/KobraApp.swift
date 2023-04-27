//
//  KobraApp.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/15/23.
//

import SwiftUI
import Firebase
import UIKit

@main
struct KobraApp: App {
    typealias imagePackageTuple = (image: UIImage, package: Package)
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomePageView()
        }
    }
}
