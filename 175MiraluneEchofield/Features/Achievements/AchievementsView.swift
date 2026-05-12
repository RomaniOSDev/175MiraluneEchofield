//
//  AchievementsView.swift
//  175MiraluneEchofield
//

import SwiftUI

private struct AchievementItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let isUnlocked: (ProgressStore) -> Bool
}

struct AchievementsView: View {
    @EnvironmentObject private var progress: ProgressStore

    private let columns = [GridItem(.adaptive(minimum: 148), spacing: 14)]

    private var items: [AchievementItem] {
        [
            AchievementItem(id: "first", title: "First Star", detail: "Earned your first star.", isUnlocked: { $0.achievementFirstStar }),
            AchievementItem(id: "challenger", title: "New Challenger", detail: "Played one activity.", isUnlocked: { $0.achievementNewChallenger }),
            AchievementItem(id: "quick", title: "Quick Start", detail: "Completed an activity under a minute.", isUnlocked: { $0.achievementQuickStart }),
            AchievementItem(id: "perfect", title: "Perfectionist", detail: "\"3 stars\" in one game.", isUnlocked: { $0.achievementPerfectionist }),
            AchievementItem(id: "pioneer", title: "Progress Pioneer", detail: "Unlocked a new level.", isUnlocked: { $0.achievementProgressPioneer }),
            AchievementItem(id: "streak", title: "Streak Seeker", detail: "Maintained a streak of three games.", isUnlocked: { $0.achievementStreakSeeker }),
            AchievementItem(id: "novice", title: "Welcome Novice", detail: "Viewed onboarding screens.", isUnlocked: { $0.achievementWelcomeNovice }),
            AchievementItem(id: "rising", title: "Rising Star", detail: "Earned at least ten stars.", isUnlocked: { $0.achievementRisingStar }),
            AchievementItem(id: "daily", title: "Spotlight Starter", detail: "Finished today's spotlight stage at least once.", isUnlocked: { $0.achievementDailyDynamo }),
            AchievementItem(id: "week", title: "Week Warrior", detail: "Earned \(ProgressStore.weeklyStarTarget) stars in one calendar week.", isUnlocked: { $0.achievementWeekWarrior }),
            AchievementItem(id: "pb", title: "Personal Best", detail: "Beat your own time or move record on a stage.", isUnlocked: { $0.achievementPersonalBestBreaker }),
            AchievementItem(id: "study", title: "Study Hall", detail: "Opened every activity how-to guide.", isUnlocked: { $0.achievementStudyHall })
        ]
    }

    var body: some View {
        ZStack {
            LayeredBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Achievements")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Collect badges for spotlight runs, weekly goals, tips, and mastery.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardDepth(
                        cornerRadius: 22,
                        elevated: false,
                        accentEdge: Color.appAccent.opacity(0.28),
                        rimLight: true
                    )

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(items) { item in
                            let unlocked = item.isUnlocked(progress)
                            AchievementBadgeView(
                                title: item.title,
                                detail: item.detail,
                                unlocked: unlocked
                            )
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
    }
}

private struct AchievementBadgeView: View {
    let title: String
    let detail: String
    let unlocked: Bool

    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: unlocked
                                ? [Color.appPrimary.opacity(0.22), Color.appSurface.opacity(0.55)]
                                : [Color.appSurface.opacity(0.4), Color.appSurface.opacity(0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.appPrimary.opacity(unlocked ? 0.5 : 0.15), lineWidth: 1)
                    )
                Image(systemName: unlocked ? "medal.fill" : "lock.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(unlocked ? Color.appAccent : Color.appTextSecondary)
                    .scaleEffect(pulse ? 1.05 : 1)
            }
            .frame(height: 86)

            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .appCardDepth(cornerRadius: 18, elevated: false, accentEdge: unlocked ? Color.appAccent : nil, rimLight: unlocked)
        .scaleEffect(unlocked ? 1 : 0.96)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: unlocked)
        .onChange(of: unlocked) { newValue in
            guard newValue else { return }
            pulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                pulse = false
            }
        }
    }
}
