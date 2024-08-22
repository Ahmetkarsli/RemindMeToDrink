//
//  HistoryView.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 22.08.24.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DrinkEntriesModel.date, order: .reverse) var drinks: [DrinkEntriesModel]
    @State private var selectedDate: Date = Date()
    @Binding var totalDrinkAmount: Double

    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.3)
                    .ignoresSafeArea()

                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                        .frame(width: 350, height: 60)
                        .overlay(
                            VStack(alignment: .center) {
                                Text("Total drink in L")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                Text("\(totalDrinkAmount, specifier: "%.1f")")
                            }
                        )
                        .padding()

                    DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding()

                    List {
                        ForEach(drinksForDay(selectedDate)) { drink in
                            VStack(alignment: .leading) {
                                Text(drink.drinkType)
                                    .font(.headline)
                                Text("Amount: \(drink.drinkAmount, specifier: "%.1f") L")
                                    .font(.subheadline)
                                Text("Time: \(formattedDate(drink.date, withTime: true))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onDelete(perform: deleteDrink)
                        .listStyle(PlainListStyle())
                        .cornerRadius(10)
                        .padding()
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Drink History")
            .onAppear {
                updateTotalDrinkAmount()
            }
            .onChange(of: selectedDate) { _,_ in
                updateTotalDrinkAmount()
            }
        }
    }

    private func updateTotalDrinkAmount() {
        totalDrinkAmount = drinksForDay(selectedDate).reduce(0) { $0 + $1.drinkAmount }
    }

    private func drinksForDay(_ day: Date) -> [DrinkEntriesModel] {
        let calendar = Calendar.current
        return drinks.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    private func formattedDate(_ date: Date, withTime: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        if withTime {
            formatter.timeStyle = .short
        }
        return formatter.string(from: date)
    }

    private func deleteDrink(at offsets: IndexSet) {
        offsets.forEach { index in
            let drinkToDelete = drinksForDay(selectedDate)[index]
            modelContext.delete(drinkToDelete)
        }
        try? modelContext.save()
        updateTotalDrinkAmount()
    }
}
