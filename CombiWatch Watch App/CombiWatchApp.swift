//
//  CombiWatchApp.swift
//  CombiWatch Watch App
//
//  Created by Christopher Barlas on 3/1/24.
//

import SwiftUI
import SwiftData

@main
struct CombiWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            LockListView()
        }.modelContainer(for: Lock.self)
    }
}
