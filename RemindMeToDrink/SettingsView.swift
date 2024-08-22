//
//  SettingsView.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 22.08.24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showInfo: Bool
    let genders = ["Male", "Female"]
    
    @Binding var selectedGender: String
    @Binding var selectedAge: Int
    @Binding var selectedWeight: Double
    
    @State private var selectedStartTime: Date = Date()
    @State private var selectedEndTime: Date = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    Text("Settings")
                        .frame(alignment: .center)
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical, 10)
                    
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.top, 20)
                    Text("This information is used to calculate your daily water intake.")
                        .padding()
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Form {
                        Section(header: Text("Personal Information")) {
                            Picker("Gender", selection: $selectedGender) {
                                ForEach(genders, id: \.self) {
                                    Text($0)
                                }
                            }
                            HStack {
                                TextField("Age", value: $selectedAge, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                
                                TextField("Weight(KG)", value: $selectedWeight, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                            }
                        }
                        Section(header: Text("Notification Settings")) {
                            DatePicker("Start Time", selection: $selectedStartTime, displayedComponents: .hourAndMinute)
                            DatePicker("End Time", selection: $selectedEndTime, displayedComponents: .hourAndMinute)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    Spacer()
                    
                    Button("Save") {
                        save()
                        saveNotificationSettings(startTime: selectedStartTime, endTime: selectedEndTime)
                        scheduleWaterReminder()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    func saveNotificationSettings(startTime: Date, endTime: Date) {
        let defaults = UserDefaults.standard
        defaults.set(startTime, forKey: "NotificationStartTime")
        defaults.set(endTime, forKey: "NotificationEndTime")
    }
    
    func loadSettings() {
        let settings = loadNotificationSettings()
        if let startTime = settings.startTime {
            selectedStartTime = startTime
        }
        if let endTime = settings.endTime {
            selectedEndTime = endTime
        }
    }
    
    func loadNotificationSettings() -> (startTime: Date?, endTime: Date?) {
        let defaults = UserDefaults.standard
        let startTime = defaults.object(forKey: "NotificationStartTime") as? Date
        let endTime = defaults.object(forKey: "NotificationEndTime") as? Date
        return (startTime, endTime)
    }
    
    // Funktion zum Planen der Erinnerung
    func scheduleWaterReminder() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let currentDate = Date()
        
        let settings = loadNotificationSettings()
        guard let startTime = settings.startTime, let endTime = settings.endTime else {
            return
        }
        
        guard currentDate >= startTime && currentDate <= endTime else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "Please don't forget to drink water."
        content.sound = UNNotificationSound.default
        
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
    
    func save() {
        showInfo.toggle()
    }
}
