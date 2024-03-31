//
//  CombiApp.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI
import SwiftData

@main
struct CombiApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(
                for: Lock.self,
                migrationPlan: LockMigrationPlan.self
            )
        }
        catch {
            fatalError("Failed to init model container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LockListView()
        }
        .modelContainer(container)
    }
}
