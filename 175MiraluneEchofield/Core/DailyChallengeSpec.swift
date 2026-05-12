//
//  DailyChallengeSpec.swift
//  175MiraluneEchofield
//

import Foundation

struct DailyChallengeSpec: Equatable {
    let activity: ActivityIdentifier
    let difficulty: DifficultyTier
    let levelIndex: Int

    static func current(for date: Date = Date(), calendar: Calendar = .current) -> DailyChallengeSpec {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        let h = Self.fnv1a64(key)
        let activities = ActivityIdentifier.allCases
        let tiers = DifficultyTier.allCases
        let activity = activities[Int(h % UInt64(activities.count))]
        let difficulty = tiers[Int((h / 10) % UInt64(tiers.count))]
        let level = Int((h / 100) % UInt64(LevelProgress.count))
        return DailyChallengeSpec(activity: activity, difficulty: difficulty, levelIndex: level)
    }

    private static func fnv1a64(_ key: String) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return hash
    }
}
