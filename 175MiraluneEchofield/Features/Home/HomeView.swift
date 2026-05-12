//
//  HomeView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: ProgressStore
    @Binding var selectedMainTab: MainTab

    private var todaySpec: DailyChallengeSpec {
        DailyChallengeSpec.current()
    }

    private var totalPossibleStars: Int {
        ActivityIdentifier.allCases.count * DifficultyTier.allCases.count * LevelProgress.count * 3
    }

    private var starCollectionFraction: Double {
        guard totalPossibleStars > 0 else { return 0 }
        return min(1, Double(progress.totalStarsEarned) / Double(totalPossibleStars))
    }

    private var weeklyFraction: Double {
        let t = Double(ProgressStore.weeklyStarTarget)
        guard t > 0 else { return 0 }
        return min(1, Double(progress.weeklyStarsEarned) / t)
    }

    private let quickPlayColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        ZStack {
            AmbientGridBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroHeader

                    TodaysSpotlightNavigateCard(spec: todaySpec)

                    HStack(alignment: .top, spacing: 14) {
                        weeklyGoalWidget
                        collectionWidget
                    }

                    sectionTitle("Quick play", subtitle: "Jump into your main modes.")
                    LazyVGrid(columns: quickPlayColumns, spacing: 14) {
                        NavigationLink(value: PlayRoute.browse(.pairTiles)) {
                            HomeQuickPlayTile(
                                title: "Pair Tiles",
                                symbol: "square.grid.3x3.fill",
                                tint: Color.appPrimary
                            )
                        }
                        .buttonStyle(.plain)
                        NavigationLink(value: PlayRoute.browse(.mysticSwipe)) {
                            HomeQuickPlayTile(
                                title: "Mystic Swipe",
                                symbol: "hand.draw.fill",
                                tint: Color.appAccent
                            )
                        }
                        .buttonStyle(.plain)
                        NavigationLink(value: PlayRoute.browse(.rhythmDuel)) {
                            HomeQuickPlayTile(
                                title: "RhythmMatch",
                                symbol: "waveform.path.ecg",
                                tint: Color.appPrimary
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    sectionTitle("Practice", subtitle: "Any stage, no progress changes.")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            NavigationLink(value: PlayRoute.practice(.pairTiles)) {
                                HomePracticeChip(title: "Pair Tiles", symbol: "square.grid.3x3.fill")
                            }
                            .buttonStyle(.plain)
                            NavigationLink(value: PlayRoute.practice(.mysticSwipe)) {
                                HomePracticeChip(title: "Mystic Swipe", symbol: "hand.draw.fill")
                            }
                            .buttonStyle(.plain)
                            NavigationLink(value: PlayRoute.practice(.rhythmDuel)) {
                                HomePracticeChip(title: "RhythmMatch", symbol: "waveform.path.ecg")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 2)
                    }

                    sectionTitle("More", subtitle: nil)
                    HStack(spacing: 12) {
                        HomeTabShortcutButton(
                            title: "Full catalog",
                            symbol: "play.circle.fill",
                            caption: "All activities"
                        ) {
                            FeedbackEffects.buttonTap()
                            selectedMainTab = .play
                        }
                        HomeTabShortcutButton(
                            title: "Badges",
                            symbol: "trophy.fill",
                            caption: "Achievements"
                        ) {
                            FeedbackEffects.buttonTap()
                            selectedMainTab = .achievements
                        }
                        HomeTabShortcutButton(
                            title: "Options",
                            symbol: "gearshape.fill",
                            caption: "Settings"
                        ) {
                            FeedbackEffects.buttonTap()
                            selectedMainTab = .settings
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
                .padding(.bottom, 8)
            }
        }
        .navigationDestination(for: PlayRoute.self) { route in
            PlayRouteDestinationView(route: route)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.35),
                            Color.appSurface.opacity(0.65),
                            Color.appAccent.opacity(0.12),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                    .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.35), lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appTextPrimary.opacity(0.12), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 56)
                        .allowsHitTesting(false)
                }
                .frame(minHeight: 132)
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(greetingLine)
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer(minLength: 8)
                    if progress.streakCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(Color.appAccent)
                            Text("\(progress.streakCount)")
                                .font(.subheadline.weight(.heavy))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(AppDepth.cardFillGradientSoft)
                                .overlay {
                                    Capsule()
                                        .strokeBorder(Color.appAccent.opacity(0.4), lineWidth: 1)
                                }
                        }
                        .appDepthShadow(elevated: false)
                    }
                }
                Text(heroSubtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 16) {
                    heroMetric(icon: "star.fill", value: "\(progress.totalStarsEarned)", label: "Stars total")
                    heroMetric(icon: "sparkles", value: progress.dailySpotlightFinishedOnce ? "On" : "Try it", label: "Spotlight")
                }
            }
            .padding(18)
        }
        .appDepthShadow(elevated: true)
    }

    private var greetingLine: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Welcome back"
        }
    }

    private var heroSubtitle: String {
        if progress.streakCount >= 3 {
            return "Keep the momentum — your streak is shining."
        }
        if progress.totalActivitiesPlayed == 0 {
            return "Pick a quick play tile or try today's spotlight."
        }
        return "Your dashboard: spotlight, goals, and one-tap play."
    }

    private func heroMetric(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Color.appTextPrimary)
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private var weeklyGoalWidget: some View {
        HomeStatCard(
            title: "Weekly goal",
            symbol: "calendar.badge.clock",
            accent: Color.appAccent,
            rimLight: true
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(progress.weeklyStarsEarned)")
                        .font(.title.weight(.heavy))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("/ \(ProgressStore.weeklyStarTarget)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer(minLength: 0)
                    if weeklyFraction >= 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appAccent)
                    }
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.appBackground.opacity(0.35))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appAccent.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * weeklyFraction))
                    }
                }
                .frame(height: 8)
                Text("Stars this week")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var collectionWidget: some View {
        HomeStatCard(
            title: "Collection",
            symbol: "star.leadinghalf.filled",
            accent: Color.appPrimary,
            rimLight: true
        ) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(Color.appBackground.opacity(0.4), lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: starCollectionFraction)
                        .stroke(
                            AngularGradient(
                                colors: [Color.appPrimary, Color.appAccent, Color.appPrimary],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(starCollectionFraction * 100))%")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.appTextPrimary)
                }
                Text("\(progress.totalStarsEarned) of \(totalPossibleStars) stars")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionTitle(_ title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Subviews

private struct HomeQuickPlayTile: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)
                .frame(height: 28)
            Text(title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Text("Play")
                    .font(.caption2.weight(.heavy))
                Image(systemName: "arrow.right")
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(Color.appAccent)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .padding(14)
        .appCardDepth(cornerRadius: 18, elevated: true, accentEdge: tint.opacity(0.35), rimLight: true)
    }
}

private struct HomePracticeChip: View {
    let title: String
    let symbol: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text("Practice")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Color.appAccent)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary.opacity(0.55))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appCardDepth(cornerRadius: 16, elevated: false, accentEdge: Color.appAccent.opacity(0.35))
    }
}

private struct HomeStatCard<Content: View>: View {
    let title: String
    let symbol: String
    let accent: Color
    var rimLight: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(accent)
                Text(title)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer(minLength: 0)
            }
            content
        }
        .padding(14)
        .appCardDepth(cornerRadius: 18, elevated: false, accentEdge: accent, rimLight: rimLight)
    }
}

private struct HomeTabShortcutButton: View {
    let title: String
    let symbol: String
    let caption: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                Text(title)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color.appTextPrimary)
                Text(caption)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            .appCardDepth(cornerRadius: 16, elevated: false, accentEdge: nil)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationStack {
        HomeView(selectedMainTab: .constant(.home))
    }
    .environmentObject(ProgressStore())
}
