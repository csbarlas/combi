//
//  ContentView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var locks: [Lock] = SampleLocks.contents
    var body: some View {
        NavigationStack {
            List {
                ForEach(locks) { lock in
                    LockListCell(lock: lock)
                }
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
                        print("hello")
                    } label: {
                        Image(systemName: "plus")
                    }
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
    ContentView()
}
