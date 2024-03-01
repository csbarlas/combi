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
                NavigationLink {
                    LockDetailView(lock: Lock.sampleLock())
                } label: {
                    LockListCell(lock: Lock.sampleLock())
                }
            }.navigationTitle("Your Locks")
        }.padding(.horizontal)
    }
}

struct LockListCell: View {
    var lock: Lock
    
    var body: some View {
        HStack {
            Text(lock.emoji)
            Text(lock.displayName ?? "Lock")
        }
    }
}

#Preview {
    LockListView()
}
