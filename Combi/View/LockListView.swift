//
//  ContentView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI
import SwiftData

struct LockListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locks: [Lock]
    @State private var showNewLock = false
    
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
                .onDelete(perform: { indexSet in
                    deleteLocks(offsets: indexSet)
                })
            }
            .navigationTitle("Your Locks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewLock = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $showNewLock, content: {
                        LockFormView()
                    })
                }
            }
        }
    }
    
    private func deleteLocks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(locks[index])
            }
        }
    }
}

struct LockListCell: View {
    var lock: Lock
    
    var body: some View {
        HStack {
            Text(lock.emoji).font(.system(size: 45))
            
            VStack(alignment: .leading, spacing: 0) {
                if let displayName = lock.displayName {
                    Text(displayName).fontWeight(.bold)
                }
                
                if let lockerNumber = lock.lockerNumber {
                    Text("No. " + lockerNumber).monospaced()
                }
                
                Text(lock.combination).monospaced()
            }
        }
    }
}

#Preview {
    LockListView()
}
