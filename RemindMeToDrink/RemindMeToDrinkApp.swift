//
//  RemindMeToDrinkApp.swift
//  RemindMeToDrink
//
//  Created by Ahmet Karsli on 08.08.24.
//

import SwiftUI
import SwiftData

@main
struct RemindMeToDrinkApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([UserDataModel.self, DrinkEntriesModel.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(for: [UserDataModel.self, DrinkEntriesModel.self])

        }
    }
}
