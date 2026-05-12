//
//  DailySpotlightHostView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct DailySpotlightHostView: View {
    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private var spec: DailyChallengeSpec {
        DailyChallengeSpec.current()
    }

    private var playLevel: Int {
        let maxIdx = progress.highestUnlockedIndex(for: spec.activity, difficulty: spec.difficulty)
        return min(spec.levelIndex, maxIdx)
    }

    private var isPlayable: Bool {
        progress.isLevelUnlocked(activity: spec.activity, difficulty: spec.difficulty, level: playLevel)
    }

    var body: some View {
        Group {
            if isPlayable {
                destination
            } else {
                lockedPlaceholder
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var destination: some View {
        switch spec.activity {
        case .pairTiles:
            Activity1View(
                difficulty: spec.difficulty,
                level: playLevel,
                isPractice: false,
                isDailySpotlight: true
            )
        case .mysticSwipe:
            Activity2View(
                difficulty: spec.difficulty,
                level: playLevel,
                isPractice: false,
                isDailySpotlight: true
            )
        case .rhythmDuel:
            Activity3View(
                difficulty: spec.difficulty,
                level: playLevel,
                isPractice: false,
                isDailySpotlight: true
            )
        }
    }

    private var lockedPlaceholder: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.appAccent)
                Text("Spotlight Locked")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Play earlier stages in this path to unlock today’s spotlight stage.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                AppPrimaryButton(title: "Back") {
                    FeedbackEffects.buttonTap()
                    dismiss()
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .appCardDepth(cornerRadius: 22, elevated: true, accentEdge: Color.appAccent.opacity(0.35))
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(LayeredBackground())
    }
}
