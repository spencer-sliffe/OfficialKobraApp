//
//  PackageViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/7/23.
//

import SwiftUI

class PackageViewModel: ObservableObject {
    @Published var images = [UIImage]()
    @Published var isLoading = true
    
    init() {
        listAllFiles()
    }
    
    func listAllFiles() {
        let storageManager = StorageManager()
        storageManager.listAllFiles { items in
            let group = DispatchGroup()
            
            for item in items {
                group.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        URLSession.shared.dataTask(with: url) { data, _, error in
                            if let data = data {
                                if let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.images.append(image)
                                    }
                                }
                            }
                            group.leave()
                        }.resume()
                    } else {
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                self.isLoading = false
                print("All images downloaded!")
            }
        }
    }
}
