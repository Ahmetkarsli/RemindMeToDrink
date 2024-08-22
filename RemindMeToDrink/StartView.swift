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
    @StateObject private var drinkData = DrinkDataViewModel()
    @State var showInfo = false
    @State private var showDailyInfo = false
    @State var showDrinkEntry = false
    @Environment(\.modelContext) var modelContext
    @State var caffeinated = false
    @State var caffeinatedDrink: Double = 0.0
    @State var dailyGoal: Double = 0.0
    
    // Daten die gespeichert werden
    @AppStorage("userAge") var userAge: Int = 0
    @AppStorage("userGender") var userGender: String = ""
    @AppStorage("userWeight") var userWeight: Double = 0.0
    @AppStorage("userDrinkAmount") var userDrinkAmount: Double = 0.0
    @AppStorage("caffeinatedIntake") var caffeinatedIntake: Double = 0.0
    @AppStorage("userDailyGoal") var userDailyGoal: Double = 0.0
    @AppStorage("userDifference") var userDifference: Double = 0.0
        
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
                            NavigationLink(destination: HistoryView(totalDrinkAmount: $userDrinkAmount)) {
                                VStack(alignment: .leading) {
                                    Section(header: Text("Today's Water Intake")) {
                                        
                                        Text("Consumed: \(userDrinkAmount, specifier: "%.1f") Liters")
                                            .font(.title2)
                                            .foregroundColor(.black)
                                            .padding(.top, 10)
                                        HStack {
                                            Text("Daily Goal: \(userDailyGoal, specifier: "%.1f")")
                                            
                                            Image(systemName: "info.circle")
                                                .foregroundStyle(.blue)
                                                .onTapGesture {
                                                    showDailyInfo.toggle()
                                                }
                                        }
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .padding(.top, 10)
                                        
                                        Text("Difference: \(userDifference, specifier: "%.1f")")
                                            .font(.title2)
                                            .padding(.top, 10)
                                        
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                            
                        )
                        .padding(.top, 40)
                        .foregroundColor(.black)

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
                        DrinkEntryView(
                            modelContext: _modelContext,
                            isDrinkEntry: $showDrinkEntry,
                            drinkAmount: $userDrinkAmount,
                            drinkType: "Water", // oder ein anderer Standardwert
                            caffeinated: $caffeinated,
                            caffeinatedDrink: $caffeinatedIntake
                        )
                        .transition(.move(edge: .bottom))
                        .ignoresSafeArea()
                    }

                }
            }
            .navigationTitle("Remind me to Drink")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: HistoryView(totalDrinkAmount: $userDrinkAmount)) {
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
                calculateDrinkDetails(weight: userWeight, drinkAmount: userDrinkAmount, caffeinatedDrink: caffeinatedDrink, gender: userGender)
                drinkData.updateTotalDrinkAmount(for: Date())
                requestNotificationPermission()
                scheduleWaterReminder()
                
            }
            .onChange(of: userDrinkAmount) { _, _ in
                calculateDrinkDetails(weight: userWeight, drinkAmount: userDrinkAmount, caffeinatedDrink: caffeinatedDrink, gender: userGender)
            }
        }
        .sheet(isPresented: $showInfo) {
            SettingsView(
                showInfo: $showInfo,
                selectedGender: $userGender,
                selectedAge: $userAge,
                selectedWeight: $userWeight
            )
        }
        .alert(isPresented: $caffeinated) {
            Alert(
                title: Text("You are drinking caffeine!"),
                message: Text("Therefore, you need to drink the same amount of water as the caffeine drink."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showDailyInfo) {
            Alert(
                title: Text("Information"),
                message: Text("Your DailyGoal is \(dailyGoal, specifier: "%.1f") Liters, but with the intake of Caffeine your Daily Goal changes."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func calculateDrinkDetails(weight: Double, drinkAmount: Double, caffeinatedDrink: Double, gender: String) {
        let baseDailyGoal: Double
        
        switch gender.lowercased() {
        case "male":
            baseDailyGoal = weight * 0.040  // 40ml pro KG bei Männer
        case "female":
            baseDailyGoal = weight * 0.030  // 30ml bei Frauen
        default:
            baseDailyGoal = weight * 0.033  // Standardwert
        }
        
        dailyGoal = baseDailyGoal
        userDailyGoal = baseDailyGoal + caffeinatedIntake
        userDifference = userDailyGoal - drinkAmount
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
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        let startTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: currentDate)!
        let endTime = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: currentDate)!
        
        guard currentDate >= startTime && currentDate <= endTime else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "Please don't forget to drink water."
        content.sound = UNNotificationSound.default
        
        // 30-Minuten-Intervall konfigurieren
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

}

#Preview {

    StartView()
        .modelContainer(for: DrinkEntriesModel.self)
    //HistoryView()
    //    .modelContainer(for: [DrinkEntriesModel.self])
    
}
