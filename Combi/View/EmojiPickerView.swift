//
//  EmojiPickerView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/25/24.
//

import SwiftUI

// Reference: https://github.com/gahntpo/ShoppingApp/blob/main/ShoppingApp/view/feedback/EmojiSelectorView.swift
struct EmojiPickerView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var selection: Emoji
    
    let cols = [GridItem(.adaptive(minimum: 44), spacing: 5)]
    let emojis = Emoji.library()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: cols) {
                ForEach(emojis) { emoji in
                    ZStack {
                        Text(emoji.emojiString)
                            .font(.title)
                            .padding(5)
                            .onTapGesture {
                                selection = emoji
                                dismiss()
                            }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    EmojiPickerView(selection: .constant(Emoji.defaultEmoji))
}
