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

enum LockType: Codable {
    case rotary
    case padlock
    case word
    case arrow
}

enum LockSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [Lock.self]
    }
    
    @Model
    class Lock: Identifiable {
        let id: UUID? = UUID()
        var emoji: Emoji = Emoji.defaultEmoji
        var numberOfSegments: Int? = 3
        var segmentLength: Int? = 2
        var acceptedValues: LockCharacterType? = LockCharacterType.numeric
        
        var displayName: String?
        var lockerNumber: String?
        var combination: String = ""
        
        init(emoji: Emoji = Emoji.defaultEmoji, displayName: String? = nil, lockerNumber: String? = nil, combination: String, numberOfSegments: Int, segmentLength: Int, acceptedValues: LockCharacterType) {
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
}

enum LockSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [Lock.self]
    }
    
    @Model
    final class Lock: Identifiable {
        let id: UUID? = UUID()
        var emoji: Emoji = Emoji.defaultEmoji
        var numberOfSegments: Int? = 3
        var segmentLength: Int? = 2
        var lockType: LockType? = LockType.rotary
        
        var displayName: String?
        var lockerNumber: String?
        var combination: String = ""
        
        init(emoji: Emoji = Emoji.defaultEmoji, displayName: String? = nil, lockerNumber: String? = nil, combination: String, numberOfSegments: Int, segmentLength: Int, lockType: LockType) {
            self.emoji = emoji
            self.displayName = displayName
            self.lockerNumber = lockerNumber
            self.combination = combination
            self.numberOfSegments = numberOfSegments
            self.segmentLength = segmentLength
            self.lockType = lockType
        }
        
        static func sampleLock() -> Lock {
            Lock(displayName: "LA Fitness Locker", lockerNumber: "1017", combination: "12 34 56", numberOfSegments: 3, segmentLength: 2, lockType: .rotary)
        }
    }
}

typealias Lock = LockSchemaV2.Lock

enum LockMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LockSchemaV1.self, LockSchemaV2.self]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: LockSchemaV1.self, toVersion: LockSchemaV2.self)
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
}

//Reference: https://www.hackingwithswift.com/quick-start/swiftdata/how-to-read-the-contents-of-a-swiftdata-database-store
extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
