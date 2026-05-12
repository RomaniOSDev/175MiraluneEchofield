//
//  TodaysSpotlightNavigateCard.swift
//  175MiraluneEchofield
//

import SwiftUI

struct TodaysSpotlightNavigateCard: View {
    @EnvironmentObject private var progress: ProgressStore
    let spec: DailyChallengeSpec

    var body: some View {
        NavigationLink(value: PlayRoute.dailySpotlight) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                    Text("Today's Spotlight")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                Text(spotlightDescription)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    spotlightPill(spec.difficulty.title)
                    spotlightPill("Stage \(spec.levelIndex + 1)")
                    if progress.dailyChallengeBestStars > 0 {
                        spotlightPill("\(progress.dailyChallengeBestStars)★ today")
                    }
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.94),
                                Color.appSurface.opacity(0.52),
                                Color.appPrimary.opacity(0.07),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTextPrimary.opacity(0.12), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 46)
                            .allowsHitTesting(false)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.appAccent.opacity(0.48), lineWidth: 1.2)
                    }
            }
            .appDepthShadow(elevated: true)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var spotlightDescription: String {
        switch spec.activity {
        case .pairTiles:
            return "A focused Pair Tiles run — same spotlight for everyone today."
        case .mysticSwipe:
            return "A Mystic Swipe spotlight — match with smooth strokes."
        case .rhythmDuel:
            return "A RhythmMatch spotlight — stay on beat and clear the grid."
        }
    }

    private func spotlightPill(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.appBackground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(AppDepth.pillGradient)
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                    }
            )
    }
}
