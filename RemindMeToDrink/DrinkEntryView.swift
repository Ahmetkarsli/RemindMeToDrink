//
//  DrinkEntryView.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 22.08.24.
//

import SwiftUI

struct DrinkEntryView: View {
    @Environment(\.modelContext) var modelContext
    @Binding var isDrinkEntry: Bool
    @Binding var drinkAmount: Double
    @State var drinking: Double = 0.0
    @State var drinkType: String = "Water"
    @Binding var caffeinated: Bool
    
    private var numberFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter
        }
    
    private let caffeinatedDrinks = [
        "cola",
        "coffee",
        "tea",
        "energy drink"
    ]
    
    private let drinks = [
        "Water",
        "Cola",
        "Coffee",
        "Tea",
        "Energy Drink",
        "Juice",
        "Milk",
        "Lemonade",
        "Soda",
        "Iced Tea",
        "Sports Drink"
    ]

    
    var body: some View {
        
        VStack {
            Text("Enter Drink Details")
                .font(.headline)
                 .padding()
                         
            HStack {
                VStack(alignment: .leading) {
                    Section {
                        TextField("Amount (L)", value: $drinking, formatter: numberFormatter)
                            .keyboardType(.decimalPad)
                    } header: {
                        Text("Amount in L")
                            .font(.caption)
                    }
                }
                VStack {
                    Section {
                        Picker("Drink", selection: $drinkType) {
                            ForEach(drinks, id: \.self) { drink in
                                Text(drink)
                            }
                        }
                    } header: {
                        Text("Drink Type")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Button("Add") {
                // Handle the drink amount addition
                if caffeinatedDrinks.contains(drinkType.lowercased()) {
                    caffeinated = true
                    
                }
                if caffeinated {
                    
                    drinkAmount += drinking
                }
                drinkAmount += drinking
                
                let drink = DrinkEntriesModel(drinkType: drinkType, drinkAmount: drinking, date: .now)
                modelContext.insert(drink)
                try? modelContext.save()
                print(drink)
                
                isDrinkEntry.toggle()
                
            }
            .font(.headline)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .frame(height: UIScreen.main.bounds.height / 4)
        .background(Color.white)
        .cornerRadius(30)
        .animation(.easeInOut(duration: 0.4), value: isDrinkEntry)
    }
}
