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
    var body: some Scene {
        WindowGroup {
            LockListView()
        }
        .modelContainer(for: Lock.self)
    }
}
