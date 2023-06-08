//
//  FoodView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/19/23.
//

import Foundation
import SwiftUI

struct FoodView: View {
    @ObservedObject var viewModel = FoodViewModel()
    @State private var isPresentingCreateFoodView = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedCuisineType: CuisineType = .italian
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Text("\(Date(), formatter: dateFormatter)")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Recipe Feed")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    
                    Text("\(Date(), formatter: timeFormatter)")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }.frame(height: 20)
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
