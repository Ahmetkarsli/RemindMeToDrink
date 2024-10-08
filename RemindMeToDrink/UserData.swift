//
//  UserData.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 08.08.24.
//

import Foundation
import SwiftData
import Combine

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

class DrinkDataViewModel: ObservableObject {
    @Published var drinks: [DrinkEntriesModel] = []
    
    func updateTotalDrinkAmount(for date: Date) {
        let calendar = Calendar.current
        drinks = drinks.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}
