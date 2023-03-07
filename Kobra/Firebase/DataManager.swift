//
//  DataManager.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/1/23.
//

import SwiftUI
import Firebase

class DataManager: ObservableObject{
    @Published var packages: [Package] = []
    
    init(){
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
                    let medal = data["medal"] as? String ?? ""
                    
                    let package = Package(id: id, medal: medal)
                    self.packages.append(package)
                }
            }
        }
    }
}
