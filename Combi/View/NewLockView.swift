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
                                        if(newValue.count > numberOfSegments * segmentLength + numberOfSpaces) {
                                            combination = oldValue
                                            return
                                        }
                                        if (newValue.count > segmentLength) {
                                            combinationInsertionMode = true
                                        }
                                    }
                                    else if oldValue.count > newValue.count {
                                        combinationInsertionMode = false
                                    }
                                    
                                    if (combinationInsertionMode) {
//                                        let spaceTriggerLength = (segmentLength * numberOfSpaces) + (numberOfSpaces + (segmentLength - 1))
//                                        if (newValue.count - 1 == spaceTriggerLength) {
//                                                combination = newValue + " "
//                                            numberOfSpaces += 1
//                                        }
                                        formatCombination()
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
                                .onChange(of: segmentLength) {
                                    formatCombination()
                                }
                                .onChange(of: numberOfSegments) {
                                    formatCombination()
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
    
    func formatCombination(oldSegmentLength: Int? = nil, oldNumberOfSegment: Int? = nil) {
        //First we strip old combination of all whitespace
        var tempCombination = combination
        tempCombination.removeAll(where: { $0 == Character(" ")} )
        numberOfSpaces = 0
        
        //Then limit string length
        let newLength = numberOfSegments * segmentLength
        let newEndIndex: String.Index
        if tempCombination.count < newLength {
            newEndIndex = tempCombination.endIndex
        } else {
            newEndIndex = tempCombination.index(tempCombination.startIndex, offsetBy: newLength - 1)
        }
        if (!tempCombination.isEmpty && tempCombination.count > newLength) { tempCombination = String(tempCombination[...newEndIndex])}
        
        //Then insert spaces
        var spacesInserted = 0
        if (tempCombination.count > segmentLength) {
            let maxNumOfSpaces = numberOfSegments - 1
            for currentSpace in 0..<maxNumOfSpaces {
                if (tempCombination.count - 1 < ((segmentLength * (currentSpace + 1)) + currentSpace)) { continue }
                tempCombination.insert(" ", at: tempCombination.index(tempCombination.startIndex, offsetBy: segmentLength * (currentSpace + 1) + currentSpace))
                spacesInserted += 1
            }
        }
        
        numberOfSpaces = spacesInserted
        combination = tempCombination
        
        
        //Then we compute how many spaces the new combo should have ???
//        var oldComboLength: Int? = nil
//        if let oldSegmentLength = oldSegmentLength {
//            oldComboLength = oldSegmentLength * numberOfSegments
//        }
//        else if let oldNumberOfSegment = oldNumberOfSegment {
//            oldComboLength = oldNumberOfSegment * segmentLength
//        }
//        
//        guard let oldComboLength = oldComboLength else { return }
    }
    
    func segmentLengthStepperLabel() -> String {
        switch selectedLockType {
        case "Padlock":
            fallthrough
        case "Rotary":
            if (segmentLength == 1) {
                return "\(segmentLength) digit / segment"
            } else {
                return "\(segmentLength) digits / segment"
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
