//
//  NewLockView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI
import SwiftData

struct EditLockFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var locks: [Lock]
    
    @State private var emoji: String
    @State private var displayName: String
    @State private var lockerNo: String
    @State private var combination: String
    
    @State private var showAlert: Bool
    @State private var alertMessage: String?
    
    let lockTypes = ["Rotary", "Padlock", "Word", "Directional"]
    @State private var selectedLockType: String
    
    @State private var numberOfSegments: Int
    @State private var segmentLength: Int
    
    @State private var numberOfSpaces: Int
    
    private var lock: Lock
    
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
                            let textField = TextField("Combination", text: $combination)
                                .monospaced()
                                .onChange(of: combination) { oldValue, newValue in
                                    if newValue.count > oldValue.count {
                                        if(newValue.count > numberOfSegments * segmentLength + numberOfSpaces) {
                                            combination = oldValue
                                            return
                                        }
                                    }
                                    formatCombination()
                                }
                                .onChange(of: segmentLength) {
                                    formatCombination()
                                }
                                .onChange(of: numberOfSegments) {
                                    formatCombination()
                                }
                            if selectedLockType == "Rotary" {
                                textField.keyboardType(.numberPad)
                            } else {
                                textField
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
            .navigationTitle("Edit Lock")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Button("Submit") {
                    saveLock()
                }
            }
            .alert(alertMessage ?? "Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func formatCombination() {
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
    
    func saveLock() {
        let verified = verifyMinimumRequirements()
        if !verified { return }
        else {
            //lock.combination = self.combination
            lock.emoji = self.emoji
            lock.combination = combination
            lock.numberOfSegments = numberOfSegments
            lock.segmentLength = segmentLength
            //TODO This will cause bugs
            lock.acceptedValues = .numeric
            lock.displayName = displayName.isEmpty ? nil : displayName
            lock.lockerNumber = lockerNo.isEmpty ? nil : lockerNo
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
        let newLock = Lock(emoji: emoji.isEmpty ? "🔒" : emoji, displayName: displayName.isEmpty ? nil : displayName, lockerNumber: lockerNo.isEmpty ? nil : lockerNo, combination: combination, numberOfSegments: self.numberOfSegments, segmentLength: self.segmentLength, acceptedValues: .numeric)
        modelContext.insert(newLock)
    }
    
    //Reference: https://stackoverflow.com/questions/68217128/variable-varname-used-before-being-initialized-in-swiftui
    init(lock: Lock) {
        self._combination = State(initialValue: lock.combination)
        self._emoji = State(initialValue: lock.emoji)
        self._displayName = State(initialValue: lock.displayName ?? "")
        self._lockerNo = State(initialValue: lock.lockerNumber ?? "")
        self._showAlert = State(initialValue: false)
        self._alertMessage = State(initialValue: nil)
        self._selectedLockType = State(initialValue: "Rotary")
        self._numberOfSegments = State(initialValue: lock.numberOfSegments)
        self._segmentLength = State(initialValue: lock.segmentLength)
        self._numberOfSpaces = State(initialValue: 0)
        self.lock = lock
    }
}


#Preview {
    EditLockFormView(lock: Lock(combination: "12 34 45", numberOfSegments: 3, segmentLength: 2, acceptedValues: .numeric))
}
