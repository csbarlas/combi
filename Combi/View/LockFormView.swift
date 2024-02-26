//
//  NewLockView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI
import SwiftData

struct LockFormView: View {
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
    
    @State private var isEmojiPopoverPresented = false
    @State private var emojiData: Emoji?
    
    private var lock: Lock?
    
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
                        .onChange(of: selectedLockType) { oldVal, newVal in
                            combination = ""
                            
                            switch selectedLockType {
                            case "Rotary":
                                numberOfSegments = 3
                                segmentLength = 2
                            case "Padlock":
                                numberOfSegments = 3
                                segmentLength = 1
                            case "Word":
                                numberOfSegments = 5
                                segmentLength = 1
                            case "Directional":
                                segmentLength = 1
                                numberOfSegments = 15
                            default:
                                numberOfSegments = 3
                                segmentLength = 2
                            }
                        }
                        
                        if (selectedLockType != "Directional") {
                            Stepper("\(numberOfSegments) segments", value: $numberOfSegments, in: 3...5)
                            Stepper(segmentLengthStepperLabel(), value: $segmentLength, in: 1...2)
                            
                        } else {
                            Grid() {
                                GridRow {
                                    Button {
                                        combination += "↑"
                                    } label: {
                                        Image(systemName: "arrow.up")
                                            .padding(5)
                                    }
                                    .font(.largeTitle)
                                    .buttonStyle(.bordered)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                GridRow {
                                    HStack(spacing: 10.0) {
                                        Button {
                                            combination += "←"
                                        } label: {
                                            Image(systemName: "arrow.left")
                                                .padding(.vertical, 5)
                                        }
                                        .font(.largeTitle)
                                        .buttonStyle(.bordered)
                                        Button {
                                            if combination.count > 0 {
                                                combination.removeLast()
                                            }
                                        } label: {
                                            Image(systemName: "delete.backward")
                                                .padding(.vertical, 5)
                                        }
                                        .font(.largeTitle)
                                        .buttonStyle(.bordered)
                                        Button {
                                            combination += "→"
                                        } label: {
                                            Image(systemName: "arrow.right")
                                                .padding(.vertical, 5)
                                        }
                                        .font(.largeTitle)
                                        .buttonStyle(.bordered)
                                    }
                                    
                                }
                                GridRow {
                                    Button {
                                        combination += "↓"
                                    } label: {
                                        Image(systemName: "arrow.down")
                                            .padding(5)
                                    }
                                    .font(.largeTitle)
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        
                        let textField = TextField("Combination", text: $combination)
                            .monospaced()
                            .onChange(of: combination) { oldValue, newValue in
                                formatCombination()
                            }
                            .onChange(of: segmentLength) {
                                formatCombination()
                            }
                            .onChange(of: numberOfSegments) {
                                formatCombination()
                            }
                            
                        if selectedLockType == "Rotary" || selectedLockType == "Padlock" {
                            textField.keyboardType(.numberPad)
                        } else if selectedLockType == "Word" {
                            textField.textInputAutocapitalization(.never)
                        } else {
                            // We are in "Directional" case with arrows
                            textField.disabled(true)
                        }
                    }
                    
                    Section(header: Text("Optional")) {
                        LockOptionalFormView(emojiSelection: $emojiData, displayName: $displayName, lockerNumber: $lockerNo)
                    }
                }
            }
            .navigationTitle(lock == nil ? "New Lock" : "Edit Lock")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Button("Submit") {
                    if let _ = lock {
                        saveLockEdits()
                    } else {
                        createNewLock()
                    }
                }
            }
            .alert(alertMessage ?? "Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func formatCombination() {
        //First we dont format directional combinations
        if selectedLockType == "Directional" {
            return
        }
        
        //Capitalize any letters for consistency
        var tempCombination = combination
        tempCombination = tempCombination.uppercased()
        
        //Then strip old combination of all whitespace
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
        } else if selectedLockType != "Directional" && (combination.count - numberOfSpaces) < numberOfSegments * segmentLength {
            alertMessage = "Combination is too short!"
            showAlert = true
            return false
        } else if !verifyFieldsValidity() {
            showAlert = true
            return false
        }
        
        return true
    }
    
    func verifyFieldsValidity() -> Bool {
        return verifyLockCharacters()
    }
    
    func verifyLockCharacters() -> Bool {
        switch selectedLockType {
        case "Rotary":
            fallthrough
        case "Padlock":
            let nonDigitRegex = try! Regex("[^0-9 ]")
            if combination.contains(nonDigitRegex) {
                alertMessage = "\(selectedLockType) combinations must only contain digits!"
                return false
            }
        case "Word":
            let nonDigitLetterRegex = try! Regex("[^0-9A-Z]")
            if combination.contains(nonDigitLetterRegex) {
                alertMessage = "\(selectedLockType) combinations must only contain digits and letters!"
                return false
            }
        case "Directional":
            //TODO: Check if only arrow emojis are used
            return true
        default:
            return false
        }
        
        return true
    }
    
    func instanceAndStoreLock() {
        let newLock = Lock(emoji: emoji.isEmpty ? "🔒" : emoji, displayName: displayName.isEmpty ? nil : displayName, lockerNumber: lockerNo.isEmpty ? nil : lockerNo, combination: combination, numberOfSegments: numberOfSegments, segmentLength: segmentLength, acceptedValues: .numeric)
        modelContext.insert(newLock)
    }
    
    func saveLockEdits() {
        let verified = verifyMinimumRequirements()
        if !verified { return }
        else {
            guard let lock = lock else { return }
            lock.emoji = self.emoji
            lock.combination = combination
            lock.numberOfSegments = numberOfSegments
            lock.segmentLength = segmentLength
            //TODO: This will cause bugs, assuming lock type
            lock.acceptedValues = .numeric
            lock.displayName = displayName.isEmpty ? nil : displayName
            lock.lockerNumber = lockerNo.isEmpty ? nil : lockerNo
            dismiss()
        }
    }
    
    // Initializer used when there is no lock to edit AKA create mode
    init() {
        self._combination = State(initialValue: "")
        self._emoji = State(initialValue: "")
        self._displayName = State(initialValue: "")
        self._lockerNo = State(initialValue: "")
        self._showAlert = State(initialValue: false)
        self._alertMessage = State(initialValue: nil)
        self._selectedLockType = State(initialValue: "Rotary")
        self._numberOfSegments = State(initialValue: 3)
        self._segmentLength = State(initialValue: 2)
        self._numberOfSpaces = State(initialValue: 0)
        self.lock = nil
    }
    
    /*
     * Initializer used when there is a lock to edit AKA edit mode
     * Reference: https://stackoverflow.com/questions/68217128/variable-varname-used-before-being-initialized-in-swiftui
     */
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
    LockFormView()
}
