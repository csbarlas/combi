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
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @Query private var locks: [Lock]
    @State private var showNewLock = false
    @State private var showDeleteDialog = false
    @State private var showProStore = false
    @State private var tappedLock: Lock?
    
    @StateObject var store: StoreManager = StoreManager()
    
    var body: some View {
        let _ = print(modelContext.sqliteCommand)
        NavigationStack {
            List {
                ForEach(locks.indices, id: \.self) { index in
                    let lock = locks[index]
                    NavigationLink {
                        LockDetailView(lock: lock)
                    } label: {
                        LockListCell(lock: lock)
                    }
                    .swipeActions {
                        Button("Delete") {
                            tappedLock = locks[index]
                            showDeleteDialog = true
                        }
                        .tint(Color.red)
                    }
                    .confirmationDialog(Text("You cannot undo this action"), isPresented: $showDeleteDialog, titleVisibility: .visible, presenting: tappedLock, actions: { item in
                        Button("Delete this lock?", role: .destructive) {
                            modelContext.delete(item)
                        }
                    })
                }
            }
            .navigationTitle("Your Locks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView().environmentObject(store)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if !store.isProPurchased && locks.count >= 3 {
                            showProStore = true
                        } else {
                            showNewLock = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .popover(isPresented: $showNewLock, content: {
                        LockFormView()
                    })
                    .popover(isPresented: $showProStore, content: {
                        StoreView().environmentObject(store)
                    })
                }
            }
        }.preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
    }
}

struct LockListCell: View {
    @AppStorage("redact") var redact: Bool = false
    var lock: Lock
    
    var body: some View {
        HStack {
            Text(lock.emoji.emojiString).font(.system(size: 45)).padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 0) {
                if let displayName = lock.displayName {
                    let displayName = Text(displayName).fontWeight(.bold)
                    
                    if redact {
                        displayName.font(.title3)
                    } else {
                        displayName
                    }
                }
                
                if let lockerNumber = lock.lockerNumber {
                    let lockerNo = Text("No. " + lockerNumber).monospaced()
                    
                    if redact {
                        lockerNo.font(.title3).bold(false)
                    } else {
                        lockerNo
                    }
                }
                
                if (!redact) {
                    Text(lock.combination).monospaced()
                }
            }
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
    let store = StoreManager()
    
    return LockListView().modelContainer(container).environmentObject(store)
}
