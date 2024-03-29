//
//  Food.swift
//  Kobra
//
//  Created by Spencer Sliffe on 5/21/23.
//

import Foundation
import Combine

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case brunch = "Brunch"
    case lunch = "Lunch"
    case teaTime = "Tea Time"
    case dinner = "Dinner"
    case supper = "Supper"
    case dessert = "Dessert"
    case snack = "Snack"
    case appetizer = "Appetizer"
    case mainCourse = "Main Course"
    case sideDish = "Side Dish"
    case salad = "Salad"
    case soup = "Soup"
    case drink = "Drink"
    case smoothie = "Smoothie"
    case dateNight = "Date Night"
    case holiday = "Holiday"
    case picnic = "Picnic"
    case bbq = "BBQ"
    case party = "Party"
    case gameNight = "Game Night"
    case movieNight = "Movie Night"
    case workoutMeal = "Workout Meal"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
    case glutenFree = "Gluten Free"
    case dairyFree = "Dairy Free"
    case lowCarb = "Low Carb"
    case keto = "Keto"
    case paleo = "Paleo"
    case familyDinner = "Family Dinner"
    case romanticDinner = "Romantic Dinner"
}

enum CuisineType: String, CaseIterable {
    case italian = "Italian"
    case american = "American"
    case mexican = "Mexican"
    case french = "French"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case indian = "Indian"
    case thai = "Thai"
    case spanish = "Spanish"
    case german = "German"
    case greek = "Greek"
    case turkish = "Turkish"
    case korean = "Korean"
    case vietnamese = "Vietnamese"
    case caribbean = "Caribbean"
    case african = "African"
    case british = "British"
    case irish = "Irish"
    case russian = "Russian"
    case middleEastern = "Middle Eastern"
    case mediterranean = "Mediterranean"
    case southern = "Southern"
    case scandinavian = "Scandinavian"
    case cajun = "Cajun"
    case malaysian = "Malaysian"
    case lebanese = "Lebanese"
    case ethiopian = "Ethiopian"
    case cuban = "Cuban"
    case brazilian = "Brazilian"
    case peruvian = "Peruvian"
    case filipino = "Filipino"
    case polynesian = "Polynesian"
    case moroccan = "Moroccan"
    case portuguese = "Portuguese"
    case hawaiian = "Hawaiian"
    case hungarian = "Hungarian"
    case australian = "Australian"
    case nepalese = "Nepalese"
    case pakistani = "Pakistani"
    case afghan = "Afghan"
    case southAfrican = "South African"
    case jamaican = "Jamaican"
    case israeli = "Israeli"
    case belgian = "Belgian"
    case indonesian = "Indonesian"
    case danish = "Danish"
    case swiss = "Swiss"
    case austrian = "Austrian"
    case argentinian = "Argentinian"
    case colombian = "Colombian"
    case chilean = "Chilean"
    case salvadorian = "Salvadorian"
    case welsh = "Welsh"
    case bangladeshi = "Bangladeshi"
    case taiwanese = "Taiwanese"
}

class Food: ObservableObject, Identifiable {
    var id: String = UUID().uuidString
    @Published var name: String
    @Published var ingredients: [String]
    @Published var steps: [String]
    @Published var image: String
    @Published var preparationTime: String
    @Published var mealType: MealType
    @Published var cuisine: CuisineType
    
    // Add timestamp property
    @Published var timestamp: Date
    
    // Add likes count and liking users properties
    @Published var likes: Int
    @Published var likingUsers: [String]

    init(id: String = UUID().uuidString, name: String, ingredients: [String], steps: [String], image: String, preparationTime: String, mealType: MealType, cuisine: CuisineType, timestamp: Date, likes: Int, likingUsers: [String]) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.steps = steps
        self.image = image
        self.preparationTime = preparationTime
        self.mealType = mealType
        self.cuisine = cuisine
        self.timestamp = timestamp
        self.likes = likes
        self.likingUsers = likingUsers
    }
}
