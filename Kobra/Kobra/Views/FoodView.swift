//
//  FoodView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 5/19/23.
//

import Foundation
import SwiftUI

struct FoodView: View {
    @ObservedObject var viewModel = FoodViewModel()
    @State private var isPresentingCreateFoodView = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedCuisineType: CuisineType = .italian

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text("Food Content Here")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.foods.filter({ $0.mealType == selectedMealType && $0.cuisine == selectedCuisineType })) { food in
                        FoodRow(food: food)
                            .environmentObject(viewModel)
                            .background(Color.clear)
                    }
                }
            }
            .background(Color.clear)
            customToolbar()
        }
        .background(Color.clear)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .sheet(isPresented: $isPresentingCreateFoodView) {
            CreateFoodView().environmentObject(viewModel)
        }
    }

    private func customToolbar() -> some View {
        HStack(spacing: 20) {
            Picker("Meal Type", selection: $selectedMealType) {
                ForEach(MealType.allCases, id: \.self) { meal in
                    Text(meal.rawValue).tag(meal)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Picker("Cuisine Type", selection: $selectedCuisineType) {
                ForEach(CuisineType.allCases, id: \.self) { cuisine in
                    Text(cuisine.rawValue).tag(cuisine)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Button(action: {
                isPresentingCreateFoodView.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(0)
            }
        }
        .padding(.bottom, 13)
        .edgesIgnoringSafeArea(.bottom)
    }
}
