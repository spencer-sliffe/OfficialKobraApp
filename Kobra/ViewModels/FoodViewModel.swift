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
            foodManager.uploadImage(image, foodId: food.id) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    var newFood = food
                    newFood.image = imageURL
                    self?.addFoodToDatabase(newFood, completion: completion)
                case .failure(let error):
                    print("Error uploading image: \(error.localizedDescription)")
                    self?.isLoading = false
                    completion?(.failure(error))
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
}
