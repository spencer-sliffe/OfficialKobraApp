//
//  CreateFoodView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/28/23.
//

import SwiftUI
import UIKit

struct CreateFoodView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @StateObject private var viewModel = FoodViewModel()
    @State private var name = ""
    @State private var ingredients = ""
    @State private var steps = ""
    @State private var preparationTime = ""
    @State private var selectedMealTypeRaw = MealType.breakfast.rawValue
    @State private var selectedCuisineRaw = CuisineType.italian.rawValue
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isMealTypeExpanded = false
    @State private var isCuisineTypeExpanded = false
    
    var selectedMealType: MealType {
        MealType(rawValue: selectedMealTypeRaw) ?? .breakfast
    }
    
    var selectedCuisine: CuisineType {
        CuisineType(rawValue: selectedCuisineRaw) ?? .italian
    }
    
    var isFoodDataValid: Bool {
        !(name.isEmpty || ingredients.isEmpty || steps.isEmpty || preparationTime.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        CustomTextField(text: $name, placeholder: "Name", characterLimit: 60)
                            .onChange(of: name) { newValue in
                                // Truncate the title if it exceeds the character limit
                                if newValue.count > 60 {
                                    ingredients = String(newValue.prefix(60))
                                }
                            }
                        CustomTextField(text: $ingredients, placeholder: "Ingredients (comma-separated)", characterLimit: 400)
                            .onChange(of: ingredients) { newValue in
                                // Truncate the title if it exceeds the character limit
                                if newValue.count > 400 {
                                    ingredients = String(newValue.prefix(400))
                                }
                            }
                        CustomTextField(text: $steps, placeholder: "Steps (comma-separated)", characterLimit: 300)
                            .onChange(of: steps) { newValue in
                                // Truncate the title if it exceeds the character limit
                                if newValue.count > 300 {
                                    steps = String(newValue.prefix(300))
                                }
                            }
                        CustomTextField(text: $preparationTime, placeholder: "Preparation Time", characterLimit: 20)
                            .onChange(of: preparationTime) { newValue in
                                // Truncate the title if it exceeds the character limit
                                if newValue.count > 400 {
                                    preparationTime = String(newValue.prefix(400))
                                }
                            }
                        DropDownMenu(
                            isExpanded: $isMealTypeExpanded,
                            options: MealType.allCases.map { $0.rawValue },
                            selection: $selectedMealTypeRaw,
                            onOptionSelected: { _ in isMealTypeExpanded.toggle() }
                        )
                        DropDownMenu(
                            isExpanded: $isCuisineTypeExpanded,
                            options: CuisineType.allCases.map { $0.rawValue },
                            selection: $selectedCuisineRaw,
                            onOptionSelected: { _ in isCuisineTypeExpanded.toggle() }
                        )
                    }
                    .padding()
                }
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .shadow(radius: 10)
                }
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Select Image")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                    ImagePicker(image: $image)
                }
                Spacer()
                Button(action: {
                    addFood()
                }) {
                    Text("Add Food")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                }
                .disabled(!isFoodDataValid) // Disable the button if food data is not valid
                .opacity(isFoodDataValid ? 1 : 0.5) // Reduce opacity if food data is not valid
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            gradientOptions[settingsViewModel.gradientIndex].0,
                            gradientOptions[settingsViewModel.gradientIndex].1
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("Create Food", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(.white)
            })
        }
    }
    
    func loadImage() {
        guard let _ = image else { return }
    }
    
    private func addFood() {
        let ingredientArray = ingredients.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let stepArray = steps.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let newFood = Food(
            name: name,
            ingredients: ingredientArray,
            steps: stepArray,
            image: "",
            preparationTime: preparationTime,
            mealType: selectedMealType,
            cuisine: selectedCuisine,
            timestamp: Date(),  // current date and time
            likes: 0,  // initial likes count is zero
            likingUsers: []  // initial liking users list is empty
        )
        
        viewModel.addFood(newFood, image: image) { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error adding food: \(error.localizedDescription)")
            }
        }
    }
}
