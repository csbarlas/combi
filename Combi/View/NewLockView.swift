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
    
    let lockTypes = ["Rotary", "Padlock", "Word", "Directional"]
    @State private var selectedLockType = "Rotary"
    
    @State private var numberOfSegments = 3
    @State private var segmentLength = 1
    
    @State private var numberOfSpaces = 0
    @State private var combinationInsertionMode = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Lock Details")) {
                        Picker("Type", selection: $selectedLockType) {
                            ForEach(lockTypes, id: \.self) { lockType in
                                    Text("\(lockType)")
                            }
                        }
                        
                        if (selectedLockType != "Directional") {
                            Stepper("\(numberOfSegments) segments", value: $numberOfSegments, in: 3...5)
                            Stepper(segmentLengthStepperLabel(), value: $segmentLength, in: 1...2)
                            TextField("Combination", text: $combination)
                                .monospaced()
                                .onChange(of: combination) { oldValue, newValue in
                                    if newValue.count > oldValue.count {
                                        combinationInsertionMode = true
                                    }
                                    else if oldValue.count > newValue.count {
                                        combinationInsertionMode = false
                                    }
                                    
                                    if (combinationInsertionMode) {
                                        let spaceTriggerLength = (segmentLength * numberOfSpaces) + (numberOfSpaces + (segmentLength - 1))
                                        if (newValue.count - 1 == spaceTriggerLength) {
                                                combination = newValue + " "
                                            numberOfSpaces += 1
                                        }
                                    } else {
                                        print("\(segmentLength) \(numberOfSpaces)")
                                        let deletionTrigger = (segmentLength * numberOfSpaces) + (numberOfSpaces - 1)
                                        if (oldValue.count - 1 == deletionTrigger) {
                                            var temp = newValue
                                            temp.remove(at: newValue.index(before: newValue.endIndex))
                                            combination = temp
                                            numberOfSpaces -= 1
                                        }
                                    }
                                }
                        }
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
    
    func formatCombination() {
        
    }
    
    func segmentLengthStepperLabel() -> String {
        switch selectedLockType {
        case "Padlock":
            fallthrough
        case "Rotary":
            if (segmentLength == 1) {
                return "\(segmentLength) number / segment"
            } else {
                return "\(segmentLength) numbers / segment"
            }
        case "Word":
            if (segmentLength == 1) {
                return "\(segmentLength) letter / segment"
            } else {
                return "\(segmentLength) letters / segment"
            }
        default:
            return ""
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
        let newLock = Lock(emoji: emoji.isEmpty ? "🔒" : emoji, displayName: displayName.isEmpty ? nil : displayName, lockerNumber: lockerNo.isEmpty ? nil : lockerNo, combination: combination, numberOfSegments: 3, segmentLength: 2, acceptedValues: .numeric)
        modelContext.insert(newLock)
    }
}

#Preview {
    NewLockView()
}
