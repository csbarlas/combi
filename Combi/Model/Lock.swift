//
//  Lock.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import Foundation
import SwiftData

enum LockCharacterType: Codable {
    case numeric
    case alphanumeric
    case directional
}

@Model
final class Lock: Identifiable {
    let id = UUID()
    let emoji: String
    let numberOfSegments: Int
    let segmentLength: Int
    let acceptedValues: LockCharacterType
    
    let displayName: String?
    let lockerNumber: String?
    let combination: String
    
    init(emoji: String = "🔒", displayName: String? = nil, lockerNumber: String? = nil, combination: String, numberOfSegments: Int, segmentLength: Int, acceptedValues: LockCharacterType) {
        self.emoji = emoji
        self.displayName = displayName
        self.lockerNumber = lockerNumber
        self.combination = combination
        self.numberOfSegments = numberOfSegments
        self.segmentLength = segmentLength
        self.acceptedValues = acceptedValues
    }
}
