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
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @Query private var locks: [Lock]
    
    @State private var displayName: String
    @State private var lockerNo: String
    @State private var combination: String
    
    @State private var showAlert: Bool
    @State private var alertMessage: String?
    
    let lockTypes = ["Rotary", "Padlock", "Word", "Arrow"]
    @State private var selectedLockType: String
    
    @State private var numberOfSegments: Int
    @State private var segmentLength: Int
    
    @State private var numberOfSpaces: Int
    
    @State private var isEmojiPopoverPresented = false
    @State private var emojiData: Emoji = Emoji.defaultEmoji
    
    @FocusState private var lockNameFocused: Bool
    @FocusState private var lockerNumberFocused: Bool
    @FocusState private var combinationFocused: Bool
    
    private var lock: Lock?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle().frame(width: 100).foregroundColor(.accentColor)
                            
                            Text(emojiData.emojiString).font(.system(size: 72)).onTapGesture(perform: {
                                isEmojiPopoverPresented = true
                            }).popover(isPresented: $isEmojiPopoverPresented, content: {
                                EmojiPickerView(selection: $emojiData)
                                    .frame(minWidth: 300, maxHeight: 200)
                                    .presentationCompactAdaptation(.popover)
                            })
                        }
                        
                        TextField("Lock Name", text: $displayName)
                            .padding()
                            .fontWeight(.bold)
                            .background(.background.quaternary)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                            .focused($lockNameFocused)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        lockNameFocused = false
                                        lockerNumberFocused = false
                                        combinationFocused = false
                                    }
                                }
                            }
                            .autocorrectionDisabled(true)
                            .keyboardType(.alphabet)
                            
                        
                        TextField("Optional: Locker No.", text: $lockerNo).monospaced().padding().fontWeight(.bold).background(.background.quaternary).clipShape(RoundedRectangle(cornerRadius: 10.0)).autocorrectionDisabled(true).keyboardType(.alphabet).focused($lockerNumberFocused)
                    }
                    
                    Picker("Type", selection: $selectedLockType) {
                        ForEach(lockTypes, id: \.self) { lockType in
                            Text("\(lockType)")
                        }
                    }
                    .padding(.vertical)
                    .pickerStyle(.segmented)
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
                        case "Arrow":
                            segmentLength = 1
                            numberOfSegments = 15
                        default:
                            numberOfSegments = 3
                            segmentLength = 2
                        }
                    }
                    
                    if (selectedLockType != "Arrow") {
                        numberControlsView(lockForm: self)
                    } else {
                        arrowControlsView(combo: $combination)
                    }
                    
                    let comboTextField = TextField("Combination", text: $combination)
                        .monospaced()
                        .padding()
                        .fontWeight(.bold)
                        .background(.background.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        .padding(.top)
                        .focused($combinationFocused)
                        .onChange(of: combination) {
                            formatCombination()
                        }
                        .onChange(of: segmentLength) {
                            formatCombination()
                        }
                        .onChange(of: numberOfSegments) {
                            formatCombination()
                        }
                    
                    if selectedLockType == "Rotary" || selectedLockType == "Padlock" {
                        comboTextField.keyboardType(.numberPad)
                    } else if selectedLockType == "Word" {
                        comboTextField.textInputAutocapitalization(.never)
                    } else {
                        // We are in "Arrow" case with arrows
                        comboTextField.disabled(true)
                    }
                    
                    Spacer()
                }
                .padding()
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
        .preferredColorScheme(ColorSchemeManager.shared.getPreferredColorScheme())
    }
    
    struct arrowControlsView: View {
        @Binding var combo: String
        
        var body: some View {
            Grid() {
                GridRow {
                    Button {
                        combo += "↑"
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
                            combo += "←"
                        } label: {
                            Image(systemName: "arrow.left")
                                .padding(.vertical, 5)
                        }
                        .font(.largeTitle)
                        .buttonStyle(.bordered)
                        Button {
                            if combo.count > 0 {
                                combo.removeLast()
                            }
                        } label: {
                            Image(systemName: "delete.backward")
                                .padding(.vertical, 5)
                        }
                        .font(.largeTitle)
                        .buttonStyle(.bordered)
                        Button {
                            combo += "→"
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
                        combo += "↓"
                    } label: {
                        Image(systemName: "arrow.down")
                            .padding(5)
                    }
                    .font(.largeTitle)
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    struct numberControlRow: View {
        var data: Binding<Int>
        //Inclusive range
        var from, to: Int
        private var minusDisabled: Bool {
            data.wrappedValue == from
        }
        
        private var plusDisabled: Bool {
            data.wrappedValue == to
        }
        
        var body: some View {
            HStack {
                Button {
                    if data.wrappedValue != from {
                        data.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .disabled(minusDisabled)
                }.padding()
                
                Text("\(data.wrappedValue)").font(.system(size: 84.0)).bold().fontDesign(.rounded)
                
                Button {
                    if data.wrappedValue != to {
                        data.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .disabled(plusDisabled)
                }.padding()
            }
        }
    }
    
    struct numberControlsView: View {
        var lockForm: LockFormView
        
        var body: some View {
            VStack(spacing: 0) {
                numberControlRow(data: lockForm.$numberOfSegments, from: 3, to: 5)
                Text("# segments").fontDesign(.rounded)
            }
            
            VStack(spacing: 0) {
                numberControlRow(data: lockForm.$segmentLength, from: 1, to: 2)
                Text(lockForm.segmentLengthLabel).fontDesign(.rounded)
            }
        }
    }
    
    func formatCombination() {
        //First we dont format directional combinations
        if selectedLockType == "Arrow" {
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
    
    var segmentLengthLabel: String {
        switch selectedLockType {
        case "Padlock":
            fallthrough
        case "Rotary":
            if (segmentLength == 1) {
                return "digit / segment"
            } else {
                return "digits / segment"
            }
        case "Word":
            if (segmentLength == 1) {
                return "letter / segment"
            } else {
                return "letters / segment"
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
        } else if displayName.isEmpty {
            alertMessage = "Please enter a lock name."
            showAlert = true
            return false
        }
        else if selectedLockType != "Arrow" && (combination.count - numberOfSpaces) < numberOfSegments * segmentLength {
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
            let nonDigitLetterRegex = try! Regex("[^0-9A-Z ]")
            if combination.contains(nonDigitLetterRegex) {
                alertMessage = "\(selectedLockType) combinations must only contain digits and letters!"
                return false
            }
        case "Arrow":
            //TODO: Check if only arrow emojis are used
            return true
        default:
            return false
        }
        
        return true
    }
    
    func instanceAndStoreLock() {
        let newLock = Lock(emoji: emojiData, displayName: displayName.isEmpty ? nil : displayName, lockerNumber: lockerNo.isEmpty ? nil : lockerNo, combination: combination, numberOfSegments: numberOfSegments, segmentLength: segmentLength, lockType: LockFormView.pickerValueToLockType(pickerValue: selectedLockType))
        modelContext.insert(newLock)
    }
    
    func saveLockEdits() {
        let verified = verifyMinimumRequirements()
        if !verified { return }
        else {
            guard let lock = lock else { return }
            lock.emoji = self.emojiData
            lock.combination = combination
            lock.numberOfSegments = numberOfSegments
            lock.segmentLength = segmentLength
            lock.lockType = LockFormView.pickerValueToLockType(pickerValue: selectedLockType)
            lock.displayName = displayName.isEmpty ? nil : displayName
            lock.lockerNumber = lockerNo.isEmpty ? nil : lockerNo
            dismiss()
        }
    }
    
    // Initializer used when there is no lock to edit AKA create mode
    init() {
        self._combination = State(initialValue: "")
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
        self._emojiData = State(initialValue: lock.emoji)
        self._displayName = State(initialValue: lock.displayName ?? "")
        self._lockerNo = State(initialValue: lock.lockerNumber ?? "")
        self._showAlert = State(initialValue: false)
        self._alertMessage = State(initialValue: nil)
        self._selectedLockType = State(initialValue: LockFormView.lockTypeToPickerValue(type: lock.lockType ?? .rotary))
        self._numberOfSegments = State(initialValue: lock.numberOfSegments ?? 3)
        self._segmentLength = State(initialValue: lock.segmentLength ?? 2)
        self._numberOfSpaces = State(initialValue: 0)
        self.lock = lock
    }
    
    static func pickerValueToLockType(pickerValue: String) -> LockType {
        switch pickerValue {
        case "Rotary":
            return .rotary
        case "Padlock":
            return .padlock
        case "Word":
            return .word
        case "Arrow":
            return .arrow
        default:
            fatalError("Could not convert picker value to a LockType")
        }
    }
    
    static func lockTypeToPickerValue(type: LockType) -> String {
        switch type {
        case .rotary:
            return "Rotary"
        case .padlock:
            return "Padlock"
        case .word:
            return "Word"
        case .arrow:
            return "Arrow"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Lock.self, configurations: config)
    let lock = Lock.sampleLock()
    container.mainContext.insert(lock)
    
    let store = StoreManager()
    return LockFormView().modelContainer(container).environmentObject(store)
}
