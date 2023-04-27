//
//  DataManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/1/23.
//

import SwiftUI
import Firebase

class FSAccountManager: ObservableObject {
    @Published var packages: [Package] = []
    
    init() {
        fetchPackages()
    }
    
    func fetchPackages() {
        packages.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Packages")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let price = data["price"] as? Double ?? 0.0
                    
                    let package = Package(id: id, name: name, price: price)
                    self.packages.append(package)
                }
            }
        }
    }
}
