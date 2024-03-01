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
    let id: UUID? = UUID()
    var emoji: String? = ""
    var numberOfSegments: Int? = 3
    var segmentLength: Int? = 2
    var acceptedValues: LockCharacterType? = LockCharacterType.numeric
    
    var displayName: String?
    var lockerNumber: String?
    var combination: String = ""
    
    init(emoji: String = "🔒", displayName: String? = nil, lockerNumber: String? = nil, combination: String, numberOfSegments: Int, segmentLength: Int, acceptedValues: LockCharacterType) {
        self.emoji = emoji
        self.displayName = displayName
        self.lockerNumber = lockerNumber
        self.combination = combination
        self.numberOfSegments = numberOfSegments
        self.segmentLength = segmentLength
        self.acceptedValues = acceptedValues
    }
    
    static func sampleLock() -> Lock {
        Lock(displayName: "LA Fitness Locker", lockerNumber: "1017", combination: "12 34 56", numberOfSegments: 3, segmentLength: 2, acceptedValues: .numeric)
    }
}
