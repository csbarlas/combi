//
//  Emoji.swift
//  Combi
//
//  Created by Christopher Barlas on 2/25/24.
//

import Foundation


// Reference: https://github.com/gahntpo/ShoppingApp/tree/main
struct Emoji: Identifiable, Equatable {
    var value: Int
    
    var emojiString: String {
        guard let unicodeValue = UnicodeScalar(value) else { return "?" }
        return String(unicodeValue)
    }
    
    var id: Int {
        return value
    }
    
    static func library() -> [Emoji] {
        let values = [0x1f512, 0x1f4da, 0x1f6b2, 0x1f3e0, 0x26bd, 0x26be, 0x1f94e, 0x1f3c0, 0x1f3d0, 0x1f3c8, 0x1f3be]
        return values.map { Emoji(value: $0) }
    }
}
