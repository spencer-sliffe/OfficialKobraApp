//
//  StorageManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 3/7/23.
//

import Foundation
import FirebaseStorage
import SwiftUI

public class StorageManager: ObservableObject {
    let storage = Storage.storage()
    let reference: StorageReference
    static let shared = StorageManager()
    init() {
        self.reference = storage.reference()
    }
    
    func upload(image: UIImage) {
        // Create a storage reference
        let storageRef = storage.reference().child("images/image.jpg")
        // Resize the image to 200px with a custom extension
        let resizedImage = image.aspectFittedToHeight(200)
        // Convert the image into JPEG and compress the quality to reduce its size
        let data = resizedImage.jpegData(compressionQuality: 0.2)
        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        // Upload the image
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }
                if let metadata = metadata {
                    print("Metadata: ", metadata)
                }
            }
        }
    }
    func downloadImage(from reference: StorageReference, completion: @escaping (UIImage?) -> Void) {
        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Error converting image data to UIImage.")
                completion(nil)
            }
        }
    }
    func listAllFiles(completion: @escaping ([StorageReference]) -> Void) {
        // Create a reference
        let storageRef = storage.reference()
        // List all items in the images folder
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error while listing all files: ", error)
                completion([])
                return
            }
            if let result = result {
                completion(result.items)
            } else {
                completion([])
            }
        }
    }
    
    func listItem() {
        // Create a reference
        let storageRef = storage.reference()
        // Create a completion handler - aka what the function should do after it listed all the items
        let handler: (StorageListResult?, Error?) -> Void = { (result, error) in
            if let error = error {
                print("error", error)
            }
            if let result = result, let item = result.items.first {
                print("item: ", item)
            }
        }
        // List the items
        storageRef.list(maxResults: 1, completion: handler)
    }
    // You can use the listItem() function above to get the StorageReference of the item you want to delete
    func deleteItem(item: StorageReference) {
        item.delete { error in
            if let error = error {
                print("Error deleting item", error)
            }
        }
    }
}

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let newWidth = size.width / size.height * newHeight
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
