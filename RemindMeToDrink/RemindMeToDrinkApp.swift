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
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(for: DrinkEntriesModel.self)
        }
    }
}
