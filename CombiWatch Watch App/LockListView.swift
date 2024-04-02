//
//  ContentView.swift
//  CombiWatch Watch App
//
//  Created by Christopher Barlas on 3/1/24.
//

import SwiftUI
import SwiftData

struct LockListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locks: [Lock]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(locks) { lock in
                    NavigationLink {
                        LockDetailView(lock: lock)
                    } label: {
                        LockListCell(lock: lock)
                    }
                }
            }.navigationTitle("Your Locks")
        }.padding(.horizontal)
    }
}

struct LockListCell: View {
    var lock: Lock
    
    var body: some View {
        HStack {
            Text(lock.emoji.emojiString)
            Text(lock.displayName ?? "Lock")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lock.self, configurations: config)
    let lock = Lock.sampleLock()
    container.mainContext.insert(lock)
    
    let lockNoNumber = Lock(displayName: "School Locker", combination: "12 34 56", numberOfSegments: 3, segmentLength: 2, lockType: .rotary)
    container.mainContext.insert(lockNoNumber)
    return LockListView().modelContainer(container)
}
