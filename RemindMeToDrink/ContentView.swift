//
//  ContentView.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 08.08.24.
//

import SwiftUI
import SwiftData
import UserNotifications

struct StartView: View {
    @State var showInfo = false
    @State private var showDrinkEntry = false
    @State private var waterConsumed: Double = 0.0
    @State private var userData = UserData(name: "", surname: "", age: 0, gender: "", weight: 0.0, drinkAmount: 0.0, additionalWaterForCaffeine: 0.0)
    @Environment(\.modelContext) var modelContext
    @Query private var user: [UserDataModel]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.8))
                        .shadow(
                            color: Color.black.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 10
                        )
                        .frame(width: 350, height: 200)
                        .overlay(
                            VStack(alignment: .leading) {
                                Section(header: Text("Today's Water Intake")) {
                                    
                                    let drinkDetails = userData.calculateDrinkDetails()
                                    
                                    Text("Consumed: \(userData.drinkAmount, specifier: "%.1f") Liters")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .padding(.top, 10)
                                    
                                    Text("Daily Goal: \(drinkDetails.needToDrink, specifier: "%.1f")")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .padding(.top, 10)
                                    
                                    Text("Difference: \(drinkDetails.drinkDifference, specifier: "%.1f")")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .padding(.top, 10)
                                    
                                    Spacer()
                                }
                            }
                                .padding()
                        )
                        .padding(.top, 40)
                    Spacer()
                    
                    Button {
                        showDrinkEntry.toggle()
                    } label: {
                        Text(showDrinkEntry ? "Cancel": "Add Drink")
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                    

                    if showDrinkEntry {
                        DrinkEntryView(isDrinkEntry: $showDrinkEntry, drinkAmount: $userData.drinkAmount, userData: $userData)
                            .transition(.move(edge: .bottom))
                            .ignoresSafeArea()
                    }

                }
            }
            .navigationTitle("Remind me to Drink")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "book")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                   Image(systemName: "person.circle")
                        .foregroundStyle(Color.accentColor)
                        .scaledToFit()
                        .onTapGesture {
                            showInfo.toggle()
                        }
                }
            }
            .onAppear {
                requestNotificationPermission()
                scheduleWaterReminder()
            }
        }
        .sheet(isPresented: $showInfo) {
            SettingsView(userData: $userData, showInfo: $showInfo)
        }
    }
    func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Permission granted for notifications.")
                } else {
                    print("Permission denied for notifications.")
                }
            }
        }
        
    func scheduleWaterReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "Please don't forget to drink water."
        content.sound = UNNotificationSound.default
        
        // 30-Minuten-Intervall konfigurieren
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

struct SettingsView: View {
    @Binding var userData: UserData
    @Binding var showInfo: Bool
    @Environment(\.modelContext) var modelContext
    @Query private var user: [UserDataModel]
    let genders = ["Male", "Female"]

    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(
                                Color.white,
                                lineWidth: 4
                            )
                        )
                        .padding(.top, 100)
                    Form {
                        Section(header: Text("Personal Information")) {
                            HStack {
                                TextField("Name", text: $userData.name)
                                TextField("Surname", text: $userData.surname)
                            }
                            Picker("Gender", selection: $userData.gender) {
                                ForEach(genders, id: \.self) {
                                    Text($0)
                                }
                            }
                            HStack {
                                TextField("Age", value: $userData.age, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                TextField("Weight(KG)", value: $userData.weight, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .foregroundStyle(.white)
                        
                        
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    Spacer()
                    
                    Button("Save") {
                        save()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
    func save() {
        let userSet = UserDataModel(name: userData.name, surname: userData.surname, age: userData.age, gender: userData.gender, weight: userData.weight, drinkAmount: userData.drinkAmount, additionalWaterForCaffeine: userData.additionalWaterForCaffeine)
        modelContext.insert(userSet)
        try? modelContext.save()
        showInfo.toggle()
    }
}

struct DrinkEntryView: View {
    @Environment(\.modelContext) var modelContext
    //var drinkEntries: [DrinkEntriesModel] = []
    @Binding var isDrinkEntry: Bool
    @Binding var drinkAmount: Double
    @Binding var userData: UserData
    @State var drinking = 0.0
    @State var drinkType = ""
    @State private var caffeinated: Bool = false

    
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
                caffeinated = caffeinatedDrinks.contains(drinkType.lowercased())
                print(caffeinated)
                
                if caffeinated {
                    userData.additionalWaterForCaffeine += drinking
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


struct HistoryView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DrinkEntriesModel.date, order: .reverse) var drinks: [DrinkEntriesModel]
    @State private var selectedDate: Date = Date()  // Standardmäßig auf das aktuelle Datum gesetzt
    @State private var totalDrinkAmount: Double = 0.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.8))
                        .shadow(
                            color: Color.black.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 10
                        )
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
                        .onDelete { IndexSet in
                            deleteDrink(at: IndexSet)
                            
                        }
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
            .onChange(of: selectedDate) { _ , _ in
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
    private func deleteDrink(at indexSet: IndexSet) {
        let drinksForSelectedDay = drinksForDay(selectedDate)
        indexSet.forEach { index in
            let drinkToDelete = drinksForSelectedDay[index]
            modelContext.delete(drinkToDelete)
        }
        try? modelContext.save()
        updateTotalDrinkAmount()
    }
}


#Preview {
    //StartView()
    //    .modelContainer(for: [DrinkEntriesModel.self])
    HistoryView()
        .modelContainer(for: [DrinkEntriesModel.self])
    
}
