//
//  FoodViewModel.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/19/23.
//

import Foundation
import Combine
import SwiftUI

class FoodViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var foods: [Food] = []
    private let foodManager = FSFoodManager.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        fetchFoods()
    }

    func uploadImage(_ image: UIImage, foodId: String, completion: @escaping (Result<String, Error>) -> Void) {
        foodManager.uploadImage(image, foodId: foodId, completion: completion)
    }

    func fetchFoods() {
        isLoading = true
        foodManager.fetchFoods { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let foods):
                    self?.foods = foods
                case .failure(let error):
                    print("Error fetching foods: \(error.localizedDescription)")
                }
            }
        }
    }

    func addFood(_ food: Food, image: UIImage? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        isLoading = true
        if let image = image {
            foodManager.addFoodWithImage(food, image: image) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success:
                        self?.fetchFoods()
                        completion?(.success(()))
                    case .failure(let error):
                        print("Error adding food with image: \(error.localizedDescription)")
                        completion?(.failure(error))
                    }
                }
            }
        } else {
            addFoodToDatabase(food, completion: completion)
        }
    }

    private func addFoodToDatabase(_ food: Food, completion: ((Result<Void, Error>) -> Void)? = nil) {
        foodManager.addFood(food) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.fetchFoods()
                    completion?(.success(()))
                case .failure(let error):
                    print("Error adding food: \(error.localizedDescription)")
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func updateLikeCount(_ food: Food, likeCount: Int, userId: String, isAdding: Bool) {
        foodManager.updateLikeCount(food, likeCount: likeCount, userId: userId, isAdding: isAdding)
        fetchFoods()
    }

    func deleteFood(_ food: Food) {
        foodManager.deleteFood(food) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.foodManager.deleteImage(imageURL: food.image) { result in  // directly using food.image
                        switch result {
                        case .success:
                            print("Image deleted successfully")
                        case .failure(let error):
                            print("Error deleting image: \(error.localizedDescription)")
                        }
                    }
                    self?.fetchFoods()
                case .failure(let error):
                    print("Error deleting food: \(error.localizedDescription)")
                }
            }
        }
    }


    func fetchUserFoods(userId: String) {
        isLoading = true
        foodManager.fetchUserFoods(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let foods):
                    self?.foods = foods
                case .failure(let error):
                    print("Error fetching user's foods: \(error.localizedDescription)")
                }
            }
        }
    }
}
