//
//  DataManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/1/23.
//

import Foundation
import Firebase

class DataManager: ObservableObject{
    @Published var packages: [Package] = []
    
    func fetchPackages() {
        packages.removeAll()
        let db = Firestore.firestore()
    }
}
