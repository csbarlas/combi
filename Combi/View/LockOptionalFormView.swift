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
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().frame(width: 100).foregroundColor(.accentColor)
                
                Text(emojiSelection == nil ? "🔒" : emojiSelection!.emojiString).font(.system(size: 72)).onTapGesture(perform: {
                    isEmojiPopoverPresented = true
                }).popover(isPresented: $isEmojiPopoverPresented, content: {
                    EmojiPickerView(selection: $emojiSelection)
                        .frame(minWidth: 300, maxHeight: 200)
                        .presentationCompactAdaptation(.popover)
                })
            }
            
            
            TextField("Display Name", text: $displayName).padding().fontWeight(.bold).background(.background.quaternary).clipShape(RoundedRectangle(cornerRadius: 10.0))
                
            
            TextField("Optional: Locker No.", text: $lockerNumber).monospaced().padding().fontWeight(.bold).background(.background.quaternary).clipShape(RoundedRectangle(cornerRadius: 10.0))
        }
    }
}

#Preview {
    LockOptionalFormView(emojiSelection: .constant(nil), displayName: .constant(""), lockerNumber: .constant(""))
}
