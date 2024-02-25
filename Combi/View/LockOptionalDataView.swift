//
//  LockOptionalDataView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/25/24.
//

import SwiftUI

struct LockOptionalDataView: View {
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
            
            
            TextField("Display Name", text: $displayName).multilineTextAlignment(.center).padding().frame(alignment: .center).fontWeight(.bold).background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(.quinary))
            
            TextField("Locker No.", text: $lockerNumber).monospaced().multilineTextAlignment(.center).padding().frame( alignment: .center).fontWeight(.bold).background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundStyle(.quinary))
        }
    }
}

#Preview {
    LockOptionalDataView(emojiSelection: .constant(nil), displayName: .constant(""), lockerNumber: .constant(""))
}
