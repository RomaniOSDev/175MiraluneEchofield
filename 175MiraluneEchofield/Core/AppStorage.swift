//
//  AppStorage.swift
//  175MiraluneEchofield
//

import Combine
import Foundation

enum ActivityIdentifier: String, CaseIterable {
    case pairTiles = "pairTiles"
    case mysticSwipe = "mysticSwipe"
    case rhythmDuel = "rhythmDuel"
}

enum DifficultyTier: String, CaseIterable, Identifiable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}

/// Number of levels per activity and difficulty (0-based indices in storage and UI "Level 1" = index 0).
enum LevelProgress {
    static let count = 15
    static var lastIndex: Int { count - 1 }
}

final class ProgressStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let totalStarsEarned = "totalStarsEarned"
        static let totalPlayTimeSeconds = "totalPlayTimeSeconds"
        static let starsPerActivityJSON = "starsPerActivityJSON"
        static let unlockedLevelsJSON = "unlockedLevelsJSON"
        static let streakCount = "streakCount"
        static let bestRecordsJSON = "bestRecordsJSON"
        static let weeklyStarsBucketId = "weeklyStarsBucketId"
        static let weeklyStarsEarned = "weeklyStarsEarned"
        static let weeklyGoalEverCompleted = "weeklyGoalEverCompleted"
        static let dailyChallengeDayKey = "dailyChallengeDayKey"
        static let dailyChallengeBestStars = "dailyChallengeBestStars"
        static let dailySpotlightFinishedOnce = "dailySpotlightFinishedOnce"
        static let hasImprovedPersonalBest = "PersonalBestImprovedOnce"
        static let hasSeenHintPairTiles = "hasSeenHintPairTiles"
        static let hasSeenHintMysticSwipe = "hasSeenHintMysticSwipe"
        static let hasSeenHintRhythmDuel = "hasSeenHintRhythmDuel"
    }

    static let weeklyStarTarget = 12

    private let defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var totalActivitiesPlayed: Int
    @Published private(set) var totalStarsEarned: Int
    @Published private(set) var totalPlayTimeSeconds: Int
    @Published private(set) var starsPerActivity: [String: [String: [Int]]]
    @Published private(set) var unlockedLevels: [String: [String: Int]]
    @Published private(set) var streakCount: Int
    @Published private(set) var bestRecords: [String: [String: [String: LevelBestRecord]]]
    @Published private(set) var weeklyStarsBucketId: Int
    @Published private(set) var weeklyStarsEarned: Int
    @Published private(set) var weeklyGoalEverCompleted: Bool
    @Published private(set) var dailyChallengeDayKey: String
    @Published private(set) var dailyChallengeBestStars: Int
    @Published private(set) var dailySpotlightFinishedOnce: Bool
    @Published private(set) var hasImprovedPersonalBest: Bool
    @Published private(set) var hasSeenHintPairTiles: Bool
    @Published private(set) var hasSeenHintMysticSwipe: Bool
    @Published private(set) var hasSeenHintRhythmDuel: Bool

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)
        weeklyStarsBucketId = defaults.integer(forKey: Keys.weeklyStarsBucketId)
        weeklyStarsEarned = defaults.integer(forKey: Keys.weeklyStarsEarned)
        weeklyGoalEverCompleted = defaults.bool(forKey: Keys.weeklyGoalEverCompleted)
        dailyChallengeDayKey = defaults.string(forKey: Keys.dailyChallengeDayKey) ?? ""
        dailyChallengeBestStars = defaults.integer(forKey: Keys.dailyChallengeBestStars)
        dailySpotlightFinishedOnce = defaults.bool(forKey: Keys.dailySpotlightFinishedOnce)
        hasImprovedPersonalBest = defaults.bool(forKey: Keys.hasImprovedPersonalBest)
        hasSeenHintPairTiles = defaults.bool(forKey: Keys.hasSeenHintPairTiles)
        hasSeenHintMysticSwipe = defaults.bool(forKey: Keys.hasSeenHintMysticSwipe)
        hasSeenHintRhythmDuel = defaults.bool(forKey: Keys.hasSeenHintRhythmDuel)

        if let data = defaults.data(forKey: Keys.bestRecordsJSON),
           let decoded = try? JSONDecoder().decode([String: [String: [String: LevelBestRecord]]].self, from: data) {
            bestRecords = decoded
        } else {
            bestRecords = [:]
        }

        if let data = defaults.data(forKey: Keys.starsPerActivityJSON),
           let decoded = try? JSONDecoder().decode([String: [String: [Int]]].self, from: data) {
            starsPerActivity = decoded
        } else {
            starsPerActivity = ProgressStore.makeDefaultStars()
        }

        if let data = defaults.data(forKey: Keys.unlockedLevelsJSON),
           let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            unlockedLevels = decoded
        } else {
            unlockedLevels = ProgressStore.makeDefaultUnlocked()
        }

        migrateProgressArraysIfNeeded()
        normalizeWeeklyAndDailyBuckets()

        NotificationCenter.default.publisher(for: .progressReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    private func migrateProgressArraysIfNeeded() {
        let n = LevelProgress.count
        let last = LevelProgress.lastIndex
        var changed = false
        var newStars = starsPerActivity

        for activity in ActivityIdentifier.allCases {
            var inner = newStars[activity.rawValue] ?? [:]
            for tier in DifficultyTier.allCases {
                var arr = inner[tier.rawValue] ?? Array(repeating: 0, count: n)
                if arr.count < n {
                    arr.append(contentsOf: Array(repeating: 0, count: n - arr.count))
                    changed = true
                } else if arr.count > n {
                    arr = Array(arr.prefix(n))
                    changed = true
                }
                inner[tier.rawValue] = arr
            }
            newStars[activity.rawValue] = inner
        }

        var newUnlocked = unlockedLevels
        for activity in ActivityIdentifier.allCases {
            var inner = newUnlocked[activity.rawValue] ?? [:]
            for tier in DifficultyTier.allCases {
                if let value = inner[tier.rawValue], value > last {
                    inner[tier.rawValue] = last
                    changed = true
                }
            }
            newUnlocked[activity.rawValue] = inner
        }

        if changed {
            starsPerActivity = newStars
            unlockedLevels = newUnlocked
            persist()
            objectWillChange.send()
        } else if newStars != starsPerActivity || newUnlocked != unlockedLevels {
            starsPerActivity = newStars
            unlockedLevels = newUnlocked
        }
    }

    private static func todayDayKey(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private static func currentWeekBucketId(calendar: Calendar = .current) -> Int {
        let year = calendar.component(.yearForWeekOfYear, from: Date())
        let week = calendar.component(.weekOfYear, from: Date())
        return year * 100 + week
    }

    private func normalizeWeeklyAndDailyBuckets() {
        let today = Self.todayDayKey()
        if dailyChallengeDayKey.isEmpty {
            dailyChallengeDayKey = today
        } else if dailyChallengeDayKey != today {
            dailyChallengeDayKey = today
            dailyChallengeBestStars = 0
        }
        let bucket = Self.currentWeekBucketId()
        if weeklyStarsBucketId == 0 {
            weeklyStarsBucketId = bucket
        } else if weeklyStarsBucketId != bucket {
            weeklyStarsBucketId = bucket
            weeklyStarsEarned = 0
        }
    }

    func bestRecord(for activity: ActivityIdentifier, difficulty: DifficultyTier, level: Int) -> LevelBestRecord? {
        guard level >= 0, level < LevelProgress.count else { return nil }
        let key = String(level)
        return bestRecords[activity.rawValue]?[difficulty.rawValue]?[key]
    }

    func hasSeenActivityHint(_ activity: ActivityIdentifier) -> Bool {
        switch activity {
        case .pairTiles: return hasSeenHintPairTiles
        case .mysticSwipe: return hasSeenHintMysticSwipe
        case .rhythmDuel: return hasSeenHintRhythmDuel
        }
    }

    func markActivityHintSeen(_ activity: ActivityIdentifier) {
        switch activity {
        case .pairTiles:
            hasSeenHintPairTiles = true
            defaults.set(true, forKey: Keys.hasSeenHintPairTiles)
        case .mysticSwipe:
            hasSeenHintMysticSwipe = true
            defaults.set(true, forKey: Keys.hasSeenHintMysticSwipe)
        case .rhythmDuel:
            hasSeenHintRhythmDuel = true
            defaults.set(true, forKey: Keys.hasSeenHintRhythmDuel)
        }
        objectWillChange.send()
    }

    @discardableResult
    private func mergeBestRecord(
        activity: ActivityIdentifier,
        difficulty: DifficultyTier,
        level: Int,
        timeSeconds: Int,
        primaryMetric: Int
    ) {
        guard level >= 0, level < LevelProgress.count else { return }
        let key = String(level)
        var activityMap = bestRecords[activity.rawValue] ?? [:]
        var tierMap = activityMap[difficulty.rawValue] ?? [:]
        let before = tierMap[key] ?? LevelBestRecord()
        let hadPrior = before.bestTimeSeconds != nil || before.bestPrimaryMetric != nil
        var merged = before
        merged.consider(time: timeSeconds, metric: primaryMetric)
        tierMap[key] = merged
        activityMap[difficulty.rawValue] = tierMap
        bestRecords[activity.rawValue] = activityMap

        var beatPrior = false
        if let oldT = before.bestTimeSeconds, timeSeconds < oldT {
            beatPrior = true
        }
        if let oldM = before.bestPrimaryMetric, primaryMetric < oldM {
            beatPrior = true
        }
        if hadPrior && beatPrior {
            hasImprovedPersonalBest = true
            defaults.set(true, forKey: Keys.hasImprovedPersonalBest)
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)
        weeklyStarsBucketId = defaults.integer(forKey: Keys.weeklyStarsBucketId)
        weeklyStarsEarned = defaults.integer(forKey: Keys.weeklyStarsEarned)
        weeklyGoalEverCompleted = defaults.bool(forKey: Keys.weeklyGoalEverCompleted)
        dailyChallengeDayKey = defaults.string(forKey: Keys.dailyChallengeDayKey) ?? ""
        dailyChallengeBestStars = defaults.integer(forKey: Keys.dailyChallengeBestStars)
        dailySpotlightFinishedOnce = defaults.bool(forKey: Keys.dailySpotlightFinishedOnce)
        hasImprovedPersonalBest = defaults.bool(forKey: Keys.hasImprovedPersonalBest)
        hasSeenHintPairTiles = defaults.bool(forKey: Keys.hasSeenHintPairTiles)
        hasSeenHintMysticSwipe = defaults.bool(forKey: Keys.hasSeenHintMysticSwipe)
        hasSeenHintRhythmDuel = defaults.bool(forKey: Keys.hasSeenHintRhythmDuel)

        if let data = defaults.data(forKey: Keys.bestRecordsJSON),
           let decoded = try? JSONDecoder().decode([String: [String: [String: LevelBestRecord]]].self, from: data) {
            bestRecords = decoded
        } else {
            bestRecords = [:]
        }

        if let data = defaults.data(forKey: Keys.starsPerActivityJSON),
           let decoded = try? JSONDecoder().decode([String: [String: [Int]]].self, from: data) {
            starsPerActivity = decoded
        } else {
            starsPerActivity = ProgressStore.makeDefaultStars()
        }

        if let data = defaults.data(forKey: Keys.unlockedLevelsJSON),
           let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) {
            unlockedLevels = decoded
        } else {
            unlockedLevels = ProgressStore.makeDefaultUnlocked()
        }

        migrateProgressArraysIfNeeded()
        normalizeWeeklyAndDailyBuckets()
    }

    private static func makeDefaultStars() -> [String: [String: [Int]]] {
        var result: [String: [String: [Int]]] = [:]
        for activity in ActivityIdentifier.allCases {
            var inner: [String: [Int]] = [:]
            for tier in DifficultyTier.allCases {
                inner[tier.rawValue] = Array(repeating: 0, count: LevelProgress.count)
            }
            result[activity.rawValue] = inner
        }
        return result
    }

    private static func makeDefaultUnlocked() -> [String: [String: Int]] {
        var result: [String: [String: Int]] = [:]
        for activity in ActivityIdentifier.allCases {
            var inner: [String: Int] = [:]
            for tier in DifficultyTier.allCases {
                inner[tier.rawValue] = 0
            }
            result[activity.rawValue] = inner
        }
        return result
    }

    func markOnboardingSeen() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        persist()
        objectWillChange.send()
    }

    func stars(for activity: ActivityIdentifier, difficulty: DifficultyTier, level: Int) -> Int {
        guard level >= 0, level < LevelProgress.count else { return 0 }
        return starsPerActivity[activity.rawValue]?[difficulty.rawValue]?[level] ?? 0
    }

    func highestUnlockedIndex(for activity: ActivityIdentifier, difficulty: DifficultyTier) -> Int {
        let raw = unlockedLevels[activity.rawValue]?[difficulty.rawValue] ?? 0
        return min(raw, LevelProgress.lastIndex)
    }

    func isLevelUnlocked(activity: ActivityIdentifier, difficulty: DifficultyTier, level: Int) -> Bool {
        level <= highestUnlockedIndex(for: activity, difficulty: difficulty)
    }

    func recordLevelCompletion(
        activity: ActivityIdentifier,
        difficulty: DifficultyTier,
        level: Int,
        earnedStars: Int,
        sessionSeconds: Int,
        completedSuccessfully: Bool,
        isPractice: Bool = false,
        isDailySpotlight: Bool = false,
        primaryMetric: Int? = nil
    ) {
        guard level >= 0, level < LevelProgress.count else { return }

        if isPractice {
            return
        }

        normalizeWeeklyAndDailyBuckets()

        if completedSuccessfully {
            let previousStars = stars(for: activity, difficulty: difficulty, level: level)
            let clamped = min(max(earnedStars, 0), 3)
            var activityMap = starsPerActivity[activity.rawValue] ?? [:]
            var tierStars = activityMap[difficulty.rawValue] ?? Array(repeating: 0, count: LevelProgress.count)
            if level < tierStars.count {
                tierStars[level] = max(tierStars[level], clamped)
            }
            activityMap[difficulty.rawValue] = tierStars
            starsPerActivity[activity.rawValue] = activityMap

            let starDelta = max(0, clamped - previousStars)
            if starDelta > 0 {
                totalStarsEarned += starDelta
                weeklyStarsEarned += starDelta
                if weeklyStarsEarned >= Self.weeklyStarTarget {
                    weeklyGoalEverCompleted = true
                    defaults.set(true, forKey: Keys.weeklyGoalEverCompleted)
                }
            }

            totalActivitiesPlayed += 1
            totalPlayTimeSeconds += max(sessionSeconds, 0)

            if clamped >= 1, level < LevelProgress.lastIndex {
                var unlockedMap = unlockedLevels[activity.rawValue] ?? [:]
                let currentMax = unlockedMap[difficulty.rawValue] ?? 0
                let proposed = max(currentMax, level + 1)
                unlockedMap[difficulty.rawValue] = min(proposed, LevelProgress.lastIndex)
                unlockedLevels[activity.rawValue] = unlockedMap
            }

            if isDailySpotlight {
                let spec = DailyChallengeSpec.current()
                if spec.activity == activity, spec.difficulty == difficulty, spec.levelIndex == level {
                    dailyChallengeBestStars = max(dailyChallengeBestStars, clamped)
                    if clamped >= 1 {
                        dailySpotlightFinishedOnce = true
                        defaults.set(true, forKey: Keys.dailySpotlightFinishedOnce)
                    }
                }
            }

            if let metric = primaryMetric {
                mergeBestRecord(
                    activity: activity,
                    difficulty: difficulty,
                    level: level,
                    timeSeconds: max(sessionSeconds, 0),
                    primaryMetric: metric
                )
            }

            streakCount += 1
        } else {
            streakCount = 0
        }

        persist()
        objectWillChange.send()
    }

    func resetAllProgress() {
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.totalStarsEarned)
        defaults.removeObject(forKey: Keys.totalPlayTimeSeconds)
        defaults.removeObject(forKey: Keys.starsPerActivityJSON)
        defaults.removeObject(forKey: Keys.unlockedLevelsJSON)
        defaults.removeObject(forKey: Keys.streakCount)
        defaults.removeObject(forKey: Keys.bestRecordsJSON)
        defaults.removeObject(forKey: Keys.weeklyStarsBucketId)
        defaults.removeObject(forKey: Keys.weeklyStarsEarned)
        defaults.removeObject(forKey: Keys.weeklyGoalEverCompleted)
        defaults.removeObject(forKey: Keys.dailyChallengeDayKey)
        defaults.removeObject(forKey: Keys.dailyChallengeBestStars)
        defaults.removeObject(forKey: Keys.dailySpotlightFinishedOnce)
        defaults.removeObject(forKey: Keys.hasImprovedPersonalBest)
        defaults.removeObject(forKey: Keys.hasSeenHintPairTiles)
        defaults.removeObject(forKey: Keys.hasSeenHintMysticSwipe)
        defaults.removeObject(forKey: Keys.hasSeenHintRhythmDuel)
        reloadFromDefaults()
        objectWillChange.send()
        NotificationCenter.default.post(name: .progressReset, object: nil)
    }

    private func persist() {
        defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding)
        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
        defaults.set(totalStarsEarned, forKey: Keys.totalStarsEarned)
        defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds)
        defaults.set(streakCount, forKey: Keys.streakCount)

        defaults.set(weeklyStarsBucketId, forKey: Keys.weeklyStarsBucketId)
        defaults.set(weeklyStarsEarned, forKey: Keys.weeklyStarsEarned)
        defaults.set(weeklyGoalEverCompleted, forKey: Keys.weeklyGoalEverCompleted)
        defaults.set(dailyChallengeDayKey, forKey: Keys.dailyChallengeDayKey)
        defaults.set(dailyChallengeBestStars, forKey: Keys.dailyChallengeBestStars)
        defaults.set(dailySpotlightFinishedOnce, forKey: Keys.dailySpotlightFinishedOnce)
        defaults.set(hasImprovedPersonalBest, forKey: Keys.hasImprovedPersonalBest)
        defaults.set(hasSeenHintPairTiles, forKey: Keys.hasSeenHintPairTiles)
        defaults.set(hasSeenHintMysticSwipe, forKey: Keys.hasSeenHintMysticSwipe)
        defaults.set(hasSeenHintRhythmDuel, forKey: Keys.hasSeenHintRhythmDuel)

        if let data = try? JSONEncoder().encode(bestRecords) {
            defaults.set(data, forKey: Keys.bestRecordsJSON)
        }

        if let data = try? JSONEncoder().encode(starsPerActivity) {
            defaults.set(data, forKey: Keys.starsPerActivityJSON)
        }
        if let data = try? JSONEncoder().encode(unlockedLevels) {
            defaults.set(data, forKey: Keys.unlockedLevelsJSON)
        }
    }

    var achievementFirstStar: Bool {
        totalStarsEarned >= 1
    }

    var achievementNewChallenger: Bool {
        totalActivitiesPlayed >= 1
    }

    var achievementQuickStart: Bool {
        guard totalActivitiesPlayed > 0 else { return false }
        let average = Double(totalPlayTimeSeconds) / Double(totalActivitiesPlayed)
        return average < 60
    }

    var achievementPerfectionist: Bool {
        for (_, tiers) in starsPerActivity {
            for (_, levels) in tiers {
                if levels.contains(3) {
                    return true
                }
            }
        }
        return false
    }

    var achievementProgressPioneer: Bool {
        for (_, tiers) in unlockedLevels {
            for (_, value) in tiers where value >= 1 {
                return true
            }
        }
        return false
    }

    var achievementStreakSeeker: Bool {
        streakCount >= 3
    }

    var achievementWelcomeNovice: Bool {
        hasSeenOnboarding
    }

    var achievementRisingStar: Bool {
        totalStarsEarned >= 10
    }

    var achievementDailyDynamo: Bool {
        dailySpotlightFinishedOnce
    }

    var achievementWeekWarrior: Bool {
        weeklyGoalEverCompleted
    }

    var achievementPersonalBestBreaker: Bool {
        hasImprovedPersonalBest
    }

    var achievementStudyHall: Bool {
        hasSeenHintPairTiles && hasSeenHintMysticSwipe && hasSeenHintRhythmDuel
    }

    func formattedBestTimeShort(_ seconds: Int) -> String {
        let s = max(seconds, 0)
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }

    func formattedPlayTime() -> String {
        let total = max(totalPlayTimeSeconds, 0)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}
