//
//  ContentView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI

struct LockListView: View {
    @State private var locks: [Lock] = SampleLocks.contents
    @State private var showNewLock = false
    
    var body: some View {
        NavigationStack {
            List(locks, id: \.id) { lock in
                NavigationLink(destination: LockDetailView(lock: lock), label: {
                    LockListCell(lock: lock)
                })
            }
            .navigationTitle("Your Locks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        print("settings")
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
                        NewLockView()
                    })
                }
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
