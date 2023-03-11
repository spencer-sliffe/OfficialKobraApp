//
//  PackageViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/7/23.
//
import Firebase
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseStorage

class PackageViewModel: ObservableObject {
    @Published var packages = [PackageWithImage]()
    @Published var isLoading = true
    
    init() {
        fetchPackages()
    }
    
    func fetchPackages() {
        let storageManager = StorageManager()
        let db = Firestore.firestore()
        let ref = db.collection("Packages")
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            if let snapshot = snapshot {
                let group = DispatchGroup()

                for document in snapshot.documents {
                    let data = document.data()

                    let id = UUID(uuidString: document.documentID) ?? UUID()
                    let medal = data["medal"] as? String ?? ""
                    let price = data["price"] as? Double ?? 0.0 // change to Double
                    var package = PackageWithImage(id: id, medal: medal, price: price)
                    self.packages.append(package)

                    let imageRef = storageManager.reference.child("images/\(medal).jpg")
                    group.enter()
                    storageManager.downloadImage(from: imageRef) { image in
                        package.image = image // update package variable with new value
                        print("Image downloaded for package with id: \(package.id)")
                        if let index = self.packages.firstIndex(where: { $0.id == package.id }) {
                            self.packages[index] = package // update the package in the array
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

}

struct PackageCell: View {
    let package: PackageWithImage
    @State private var isImageDownloaded = false

    var body: some View {
        VStack {
            Text("\(package.medal)")
            Text("\(package.price)")
            if isImageDownloaded, let image = package.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(Color.clear)
            } else {
                ProgressView()
            }
        }
        .background(Color.clear) // add this line to set the background color to clear
        .onAppear {
            if package.image != nil {
                isImageDownloaded = true
            }
        }
    }
}
