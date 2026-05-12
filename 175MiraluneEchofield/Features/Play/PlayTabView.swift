//
//  PlayTabView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct PlayTabView: View {
    @EnvironmentObject private var progress: ProgressStore

    private var todaySpec: DailyChallengeSpec {
        DailyChallengeSpec.current()
    }

    var body: some View {
        ZStack {
            AmbientGridBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose an activity")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Train focus, earn stars, unlock every stage.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardDepth(
                        cornerRadius: 22,
                        elevated: false,
                        accentEdge: Color.appPrimary.opacity(0.28),
                        rimLight: true
                    )

                    TodaysSpotlightNavigateCard(spec: todaySpec)

                    VStack(spacing: 14) {
                        NavigationLink(value: PlayRoute.browse(.pairTiles)) {
                            ActivityIntroCard(
                                title: "Pair Tiles",
                                subtitle: "Classic flip and match on a square grid.",
                                symbol: "square.grid.3x3.fill"
                            )
                        }

                        NavigationLink(value: PlayRoute.browse(.mysticSwipe)) {
                            ActivityIntroCard(
                                title: "Mystic Swipe Match",
                                subtitle: "Swipe across two neighbors to reveal a pair.",
                                symbol: "hand.draw.fill"
                            )
                        }

                        NavigationLink(value: PlayRoute.browse(.rhythmDuel)) {
                            ActivityIntroCard(
                                title: "RhythmMatch Duel",
                                subtitle: "Hold to charge flips, sync timing, clear the grid.",
                                symbol: "waveform.path.ecg"
                            )
                        }
                    }

                    Text("Practice")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.top, 8)

                    Text("Replay any stage with no changes to progress.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 12) {
                        NavigationLink(value: PlayRoute.practice(.pairTiles)) {
                            PracticeRowLabel(title: "Pair Tiles", symbol: "square.grid.3x3.fill")
                        }
                        NavigationLink(value: PlayRoute.practice(.mysticSwipe)) {
                            PracticeRowLabel(title: "Mystic Swipe Match", symbol: "hand.draw.fill")
                        }
                        NavigationLink(value: PlayRoute.practice(.rhythmDuel)) {
                            PracticeRowLabel(title: "RhythmMatch Duel", symbol: "waveform.path.ecg")
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
        }
        .navigationDestination(for: PlayRoute.self) { route in
            PlayRouteDestinationView(route: route)
        }
        .navigationTitle("Play")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
    }

}

private struct PracticeRowLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appSurface.opacity(0.9))
                )
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text("Practice")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color.appAccent)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
        .appCardDepth(cornerRadius: 16, elevated: false, accentEdge: Color.appPrimary.opacity(0.25))
    }
}

private struct ActivityIntroCard: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppDepth.cardFillGradientSoft)
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(AppDepth.cardBorderGradient(accent: nil), lineWidth: 1)
                    )
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.appPrimary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appAccent)
        }
        .padding(16)
        .appCardDepth(cornerRadius: 18, elevated: true, accentEdge: nil, rimLight: true)
    }
}
