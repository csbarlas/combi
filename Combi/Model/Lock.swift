//
//  Lock.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import Foundation
import SwiftData

@Model
final class Lock: Identifiable {
    let id = UUID()
    let emoji: String
    let displayName: String?
    let lockerNumber: String?
    let combination: String
    
    init(emoji: String = "🔒", displayName: String? = nil, lockerNumber: String? = nil, combination: String) {
        self.emoji = emoji
        self.displayName = displayName
        self.lockerNumber = lockerNumber
        self.combination = combination
    }
}
