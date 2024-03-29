//
//  FSFoodManager.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/19/23.
//

import Foundation
import FirebaseFirestore
import Firebase
import SwiftUI
import FirebaseStorage

class FSFoodManager {
    private init() {}
    static let shared = FSFoodManager()
    private let db = Firestore.firestore()
    private let foodsCollection = "Foods"
    
    func fetchFoods(completion: @escaping (Result<[Food], Error>) -> Void) {
        db.collection(foodsCollection).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var foods: [Food] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let food = self.createFoodFrom(data: data)
                foods.append(food)
            }
            completion(.success(foods))
        }
    }
    
    func deleteFood(_ food: Food, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(foodsCollection).document(food.id).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func uploadImage(_ image: UIImage, foodId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "AppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let storageRef = Storage.storage().reference().child("food_images/\(foodId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "AppDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    private func createFoodFrom(data: [String: Any]) -> Food {
        let id = data["id"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let ingredients = data["ingredients"] as? [String] ?? []
        let steps = data["steps"] as? [String] ?? []
        let image = data["image"] as? String ?? ""
        let preparationTime = data["preparationTime"] as? String ?? ""
        let mealType = MealType(rawValue: data["mealType"] as? String ?? "") ?? .breakfast
        let cuisine = CuisineType(rawValue: data["cuisine"] as? String ?? "") ?? .italian
        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let likes = data["likes"] as? Int ?? 0
        let likingUsers = data["likingUsers"] as? [String] ?? []
        
        return Food(id: id, name: name, ingredients: ingredients, steps: steps, image: image, preparationTime: preparationTime, mealType: mealType, cuisine: cuisine, timestamp: timestamp, likes: likes, likingUsers: likingUsers)
    }
    
    func addFood(_ food: Food, completion: @escaping (Result<Void, Error>) -> Void) {
        let data: [String: Any] = [
            "id": food.id,
            "name": food.name,
            "ingredients": food.ingredients,
            "steps": food.steps,
            "image": food.image,
            "preparationTime": food.preparationTime,
            "mealType": food.mealType.rawValue,
            "cuisine": food.cuisine.rawValue
        ]
        db.collection(foodsCollection).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateLikeCount(_ food: Food, likeCount: Int, userId: String, isAdding: Bool) {
        let foodId = food.id
        
        let query = db.collection(foodsCollection).whereField("id", isEqualTo: foodId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error updating like count: \(error.localizedDescription)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No document found with matching food id")
                return
            }
            
            document.reference.updateData([
                "likes": likeCount,
                "likingUsers": isAdding ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId])
            ]) { error in
                if let error = error {
                    print("Error updating like count: \(error.localizedDescription)")
                } else {
                    print("Like count updated successfully")
                }
            }
        }
    }
    
    func addFoodWithImage(_ food: Food, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        self.addFood(food) { result in
            switch result {
            case .success:
                self.uploadImage(image, foodId: food.id) { result in
                    switch result {
                    case .success(let imageURL):
                        self.updateImageURLForFood(food, imageURL: imageURL, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateImageURLForFood(_ food: Food, imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = food.id
        let foodRef = db.collection(foodsCollection).document(id)
        foodRef.updateData([
            "imageURL": imageURL
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteImage(imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageURL)
        
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchUserFoods(userId: String, completion: @escaping (Result<[Food], Error>) -> Void) {
        db.collection(foodsCollection).whereField("user", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var foods: [Food] = []
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let food = self.createFoodFrom(data: data)
                foods.append(food)
            }
            completion(.success(foods))
        }
    }
}
