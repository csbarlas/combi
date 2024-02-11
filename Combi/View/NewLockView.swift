//
//  NewLockView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI
import SwiftData

struct NewLockView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var locks: [Lock]
    
    @State private var emoji = ""
    @State private var displayName = ""
    @State private var lockerNo = ""
    @State private var combination = ""
    
    @State private var showAlert = false
    @State private var alertMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Lock Details")) {
                        TextField("Combination", text: $combination).monospaced()
                    }
                    
                    Section(header: Text("Optional")) {
                        TextField("Emoji", text: $emoji)
                        TextField("Nickname", text: $displayName)
                        TextField("Locker Number", text: $lockerNo).monospaced()
                    }
                }
            }
            .navigationTitle("New Lock")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Button("Submit") {
                    createNewLock()
                }
            }
            .alert(alertMessage ?? "Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func createNewLock() {
        let verified = verifyMinimumRequirements()
        if !verified { return }
        else {
            instanceAndStoreLock()
            dismiss()
        }
    }
    
    func verifyMinimumRequirements() -> Bool {
        if combination.isEmpty {
            alertMessage = "Please enter a combination."
            showAlert = true
            return false
        }
        
        return true
    }
    
    func instanceAndStoreLock() {
        let newLock = Lock(emoji: emoji.isEmpty ? "🔒" : emoji, displayName: displayName.isEmpty ? nil : displayName, lockerNumber: lockerNo.isEmpty ? nil : lockerNo, combination: combination)
        modelContext.insert(newLock)
    }
}

#Preview {
    NewLockView()
}
