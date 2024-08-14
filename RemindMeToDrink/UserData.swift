//
//  UserData.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 08.08.24.
//

import Foundation
import SwiftData

struct UserData {
    var name: String
    var surname: String
    var age: Int
    var gender: String
    var weight: Double
    var drinkAmount: Double
    var additionalWaterForCaffeine: Double = 0.0
    
    
    func calculateDrinkDetails() -> (needToDrink: Double, drinkDifference: Double) {
        let baseDailyGoal = weight * 0.033  // Basis-Tagesziel (Zufallswert: 33ml pro kg)
        let totalDailyGoal = baseDailyGoal + additionalWaterForCaffeine
        let difference = totalDailyGoal - drinkAmount
        return (needToDrink: totalDailyGoal, drinkDifference: difference)
    }
}


@Model
class UserDataModel: ObservableObject {
    var name: String
    var surname: String
    var age: Int
    var gender: String
    var weight: Double
    var drinkAmount: Double
    var additionalWaterForCaffeine: Double

    
    init(name: String, surname: String, age: Int, gender: String, weight: Double, drinkAmount: Double, additionalWaterForCaffeine: Double) {
        self.name = name
        self.surname = surname
        self.age = age
        self.gender = gender
        self.weight = weight
        self.drinkAmount = drinkAmount
        self.additionalWaterForCaffeine = additionalWaterForCaffeine
    }
}

@Model
class DrinkEntriesModel {
    var drinkType: String
    var drinkAmount: Double {
        didSet {
            totalDrink += drinkAmount
        }
    }
    var totalDrink: Double
    var date: Date
    
    init(drinkType: String, drinkAmount: Double, totalDrink: Double = 0.0, date: Date) {
        self.drinkType = drinkType
        self.drinkAmount = drinkAmount
        self.totalDrink = totalDrink + drinkAmount
        self.date = date
    }
}
