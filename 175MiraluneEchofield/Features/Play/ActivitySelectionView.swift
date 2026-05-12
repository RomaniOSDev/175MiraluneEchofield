//
//  ActivitySelectionView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct ActivitySelectionView: View {
    let activity: ActivityIdentifier
    let practiceMode: Bool
    @EnvironmentObject private var progress: ProgressStore
    @State private var difficulty: DifficultyTier = .easy
    @State private var appearPhase = false
    @State private var showHintSheet = false

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 156, maximum: 220), spacing: 14, alignment: .top)]
    }

    init(activity: ActivityIdentifier, practiceMode: Bool = false) {
        self.activity = activity
        self.practiceMode = practiceMode
    }

    var body: some View {
        ZStack {
            LayeredBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    heroCard

                    difficultyPicker

                    stagesSection

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(0..<LevelProgress.count, id: \.self) { level in
                            let unlocked = practiceMode || progress.isLevelUnlocked(activity: activity, difficulty: difficulty, level: level)
                            let stars = progress.stars(for: activity, difficulty: difficulty, level: level)
                            let locked = practiceMode ? false : !progress.isLevelUnlocked(activity: activity, difficulty: difficulty, level: level)
                            NavigationLink {
                                destination(for: level)
                            } label: {
                                LevelStageCell(
                                    levelNumber: level + 1,
                                    stars: stars,
                                    locked: locked,
                                    bestSubtitle: bestLine(for: level)
                                )
                            }
                            .buttonStyle(LevelCellNavButtonStyle())
                            .disabled(!unlocked)
                            .opacity(appearPhase ? 1 : 0)
                            .offset(y: appearPhase ? 0 : 14)
                            .animation(
                                .spring(response: 0.48, dampingFraction: 0.78)
                                    .delay(Double(level) * 0.028),
                                value: appearPhase
                            )
                        }
                    }
                    .id(difficulty)
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
        }
        .navigationTitle(practiceMode ? "Practice" : "Levels")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    FeedbackEffects.buttonTap()
                    showHintSheet = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                .accessibilityLabel("How to play")
            }
        }
        .sheet(isPresented: $showHintSheet) {
            ActivityHintSheet(activity: activity)
                .environmentObject(progress)
        }
        .onAppear {
            appearPhase = true
            if progress.hasSeenActivityHint(activity) == false {
                DispatchQueue.main.async {
                    showHintSheet = true
                }
            }
        }
        .onChange(of: difficulty) { _ in
            appearPhase = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                appearPhase = true
            }
        }
    }

    private var heroCard: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.45),
                                Color.appSurface.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.45), lineWidth: 1.5)
                    )

                Image(systemName: activityHeroSymbol)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .shadow(color: Color.appPrimary.opacity(0.35), radius: 6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(headerTitle)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                Text(practiceMode
                     ? "Practice runs never change stars, unlocks, or spotlight progress."
                     : "Pick a difficulty, then choose a stage. Earn stars to open the next path.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.42),
                            Color.appSurface.opacity(0.78),
                            Color.appAccent.opacity(0.08),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appTextPrimary.opacity(0.11), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 52)
                        .allowsHitTesting(false)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(AppDepth.cardBorderGradient(accent: Color.appAccent.opacity(0.35)), lineWidth: 1.2)
                }
        }
        .appDepthShadow(elevated: true)
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Difficulty")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .tracking(1.1)

            HStack(spacing: 10) {
                ForEach(DifficultyTier.allCases) { tier in
                    let selected = difficulty == tier
                    Button {
                        FeedbackEffects.buttonTap()
                        withAnimation(.easeInOut(duration: 0.28)) {
                            difficulty = tier
                        }
                    } label: {
                        Text(tier.title)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .foregroundStyle(selected ? Color.appBackground : Color.appTextPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selected ? AppDepth.primaryControlGradient : AppDepth.cardFillGradientSoft)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        Color.appPrimary.opacity(selected ? 0.65 : 0.22),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .frame(minHeight: 44)
                }
            }
        }
    }

    private var stagesSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("Stages")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("\(LevelProgress.count)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color.appBackground)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(AppDepth.pillGradient)
                        .overlay { Capsule().strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1) }
                }

            Spacer()
        }
        .padding(.top, 4)
    }

    private var activityHeroSymbol: String {
        switch activity {
        case .pairTiles:
            return "square.grid.3x3.fill"
        case .mysticSwipe:
            return "hand.draw.fill"
        case .rhythmDuel:
            return "waveform.path.ecg"
        }
    }

    private var headerTitle: String {
        switch activity {
        case .pairTiles:
            return "Pair Tiles"
        case .mysticSwipe:
            return "Mystic Swipe Match"
        case .rhythmDuel:
            return "RhythmMatch Duel"
        }
    }

    private var metricUnit: String {
        switch activity {
        case .pairTiles: return "moves"
        case .mysticSwipe: return "swipes"
        case .rhythmDuel: return "moves"
        }
    }

    private func bestLine(for level: Int) -> String? {
        guard let record = progress.bestRecord(for: activity, difficulty: difficulty, level: level),
              let time = record.bestTimeSeconds,
              let metric = record.bestPrimaryMetric else {
            return nil
        }
        return "Best \(progress.formattedBestTimeShort(time)) · \(metric) \(metricUnit)"
    }

    @ViewBuilder
    private func destination(for level: Int) -> some View {
        switch activity {
        case .pairTiles:
            Activity1View(difficulty: difficulty, level: level, isPractice: practiceMode, isDailySpotlight: false)
        case .mysticSwipe:
            Activity2View(difficulty: difficulty, level: level, isPractice: practiceMode, isDailySpotlight: false)
        case .rhythmDuel:
            Activity3View(difficulty: difficulty, level: level, isPractice: practiceMode, isDailySpotlight: false)
        }
    }
}

private struct LevelCellNavButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.38, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
