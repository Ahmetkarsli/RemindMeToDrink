//
//  RemindMeToDrinkApp.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 08.08.24.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct RemindMeToDrinkApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([UserDataModel.self, DrinkEntriesModel.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(for: [UserDataModel.self, DrinkEntriesModel.self])

        }
    }
}

class AppState: ObservableObject {
    func saveData() {
        // Deine Logik zum Speichern von Daten
        print("App is going to background. Save data here.")
        // Beispiel: Speichern in UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "LastSaveDate")
    }
}
