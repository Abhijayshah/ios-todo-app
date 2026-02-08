//
//  todo_iosApp.swift
//  todo-ios
//
//  Created by Abhijay Shah on 09/02/26.
//

import SwiftUI
import CoreData

@main
struct todo_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
