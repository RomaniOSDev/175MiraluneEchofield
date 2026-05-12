//
//  AchievementSnapshot.swift
//  175MiraluneEchofield
//

import Foundation

struct AchievementSnapshot: Equatable {
    let firstStar: Bool
    let challenger: Bool
    let quick: Bool
    let perfect: Bool
    let pioneer: Bool
    let streak: Bool
    let novice: Bool
    let rising: Bool
    let dailyDynamo: Bool
    let weekWarrior: Bool
    let personalBest: Bool
    let studyHall: Bool

    init(progress: ProgressStore) {
        firstStar = progress.achievementFirstStar
        challenger = progress.achievementNewChallenger
        quick = progress.achievementQuickStart
        perfect = progress.achievementPerfectionist
        pioneer = progress.achievementProgressPioneer
        streak = progress.achievementStreakSeeker
        novice = progress.achievementWelcomeNovice
        rising = progress.achievementRisingStar
        dailyDynamo = progress.achievementDailyDynamo
        weekWarrior = progress.achievementWeekWarrior
        personalBest = progress.achievementPersonalBestBreaker
        studyHall = progress.achievementStudyHall
    }

    func hasNewUnlock(comparedTo current: AchievementSnapshot) -> Bool {
        let previous = self
        if current.firstStar && !previous.firstStar { return true }
        if current.challenger && !previous.challenger { return true }
        if current.quick && !previous.quick { return true }
        if current.perfect && !previous.perfect { return true }
        if current.pioneer && !previous.pioneer { return true }
        if current.streak && !previous.streak { return true }
        if current.novice && !previous.novice { return true }
        if current.rising && !previous.rising { return true }
        if current.dailyDynamo && !previous.dailyDynamo { return true }
        if current.weekWarrior && !previous.weekWarrior { return true }
        if current.personalBest && !previous.personalBest { return true }
        if current.studyHall && !previous.studyHall { return true }
        return false
    }
}
