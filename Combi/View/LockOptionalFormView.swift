//
//  LockOptionalDataView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/25/24.
//

import SwiftUI

struct LockOptionalFormView: View {
    @Binding var emojiSelection: Emoji?
    @Binding var displayName: String
    @Binding var lockerNumber: String
    @State private var isEmojiPopoverPresented = false
    
    @FocusState private var lockNameFocused: Bool
    @FocusState private var lockerNumberFocused: Bool
    
    var body: some View {
        
    }
}

#Preview {
    LockOptionalFormView(emojiSelection: .constant(nil), displayName: .constant(""), lockerNumber: .constant(""))
}
