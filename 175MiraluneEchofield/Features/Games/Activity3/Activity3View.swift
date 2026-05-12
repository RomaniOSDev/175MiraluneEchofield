//
//  Activity3View.swift
//  175MiraluneEchofield
//

import SwiftUI

struct Activity3View: View {
    let difficulty: DifficultyTier
    let isPractice: Bool
    let isDailySpotlight: Bool

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: Activity3ViewModel
    @State private var activeLevel: Int
    @State private var recordedOutcome = false
    @State private var snapshot: AchievementSnapshot?

    init(difficulty: DifficultyTier, level: Int, isPractice: Bool = false, isDailySpotlight: Bool = false) {
        self.difficulty = difficulty
        self.isPractice = isPractice
        self.isDailySpotlight = isDailySpotlight
        _activeLevel = State(initialValue: level)
        _viewModel = StateObject(wrappedValue: Activity3ViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    statsHeader
                    board
                        .padding(10)
                        .appCardDepth(cornerRadius: 20, elevated: false, accentEdge: Color.appPrimary.opacity(0.12))
                    Text("Press and hold each tile for two seconds, then release to lock it.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }

            if viewModel.showResult {
                GameResultView(
                    isSuccess: viewModel.resultSuccess,
                    stars: viewModel.resultStars,
                    primaryMetricTitle: "Rhythm Moves",
                    primaryMetricValue: "\(viewModel.moves)",
                    showAchievementBanner: !isPractice && bannerUnlocked,
                    showNextLevel: viewModel.resultSuccess && activeLevel < LevelProgress.lastIndex && !isPractice && !isDailySpotlight,
                    onNextLevel: {
                        advanceLevel()
                    },
                    onRetry: {
                        resetRecording()
                        viewModel.restart(difficulty: difficulty, level: activeLevel)
                    },
                    onBackToLevels: {
                        dismiss()
                    }
                )
            }
        }
        .navigationTitle("RhythmMatch Duel")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
        .onAppear {
            if snapshot == nil {
                snapshot = AchievementSnapshot(progress: progress)
            }
        }
        .onChange(of: viewModel.showResult) { newValue in
            guard newValue, recordedOutcome == false else { return }
            recordedOutcome = true
            let seconds = max(viewModel.elapsedSeconds, 0)
            if viewModel.resultSuccess {
                progress.recordLevelCompletion(
                    activity: .rhythmDuel,
                    difficulty: difficulty,
                    level: activeLevel,
                    earnedStars: viewModel.resultStars,
                    sessionSeconds: seconds,
                    completedSuccessfully: true,
                    isPractice: isPractice,
                    isDailySpotlight: isDailySpotlight,
                    primaryMetric: viewModel.moves
                )
            } else {
                progress.recordLevelCompletion(
                    activity: .rhythmDuel,
                    difficulty: difficulty,
                    level: activeLevel,
                    earnedStars: 0,
                    sessionSeconds: seconds,
                    completedSuccessfully: false,
                    isPractice: isPractice,
                    isDailySpotlight: false,
                    primaryMetric: nil
                )
            }
        }
    }

    private var bannerUnlocked: Bool {
        guard let old = snapshot else { return false }
        return old.hasNewUnlock(comparedTo: AchievementSnapshot(progress: progress))
    }

    private var statsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Level \(activeLevel + 1)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(difficulty.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                if isPractice {
                    Text("Practice · no progress saved")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                } else if isDailySpotlight {
                    Text("Today's spotlight")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("Mistakes \(viewModel.wrongMatches)/3")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(timeString)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(16)
        .appCardDepth(cornerRadius: 16, elevated: false, accentEdge: Color.appPrimary.opacity(0.25))
    }

    private var timeString: String {
        let total = viewModel.elapsedSeconds
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var board: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 6
            let columns = max(viewModel.columns, 1)
            let rows = max(viewModel.rows, 1)
            let cellWidth = (geo.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            let cellHeight = cellWidth

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { column in
                            let index = row * columns + column
                            tileView(at: index, size: CGSize(width: cellWidth, height: cellHeight))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func tileView(at index: Int, size: CGSize) -> some View {
        if let card = viewModel.slots[index] {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppDepth.gameTileFaceGradient)
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTextPrimary.opacity(0.1), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 14)
                            .allowsHitTesting(false)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.appPrimary.opacity(card.isMatched ? 0.65 : 0.25), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                Color.appAccent.opacity(card.isFaceUp && !card.isMatched ? 0.55 : 0),
                                lineWidth: 2
                            )
                    )
                    .scaleEffect(1 + CGFloat((viewModel.pressProgress[index] ?? 0) * 0.08))

                if card.isFaceUp || card.isMatched {
                    Image(systemName: viewModel.symbolName(for: card.symbolIndex))
                        .font(.system(size: size.width * 0.34, weight: .bold))
                        .foregroundStyle(card.isDecoy ? Color.appTextSecondary : Color.appAccent)
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.35))
                        .padding(8)
                }

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .trim(from: 0, to: viewModel.pressProgress[index] ?? 0)
                    .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(2)
            }
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.12), value: viewModel.pressProgress[index])
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        viewModel.touchDown(on: index)
                    }
                    .onEnded { _ in
                        viewModel.touchUp(on: index)
                    }
            )
            .disabled(card.isMatched || viewModel.showResult || viewModel.isPreviewing)
        } else {
            Color.clear
                .frame(width: size.width, height: size.height)
        }
    }

    private func advanceLevel() {
        guard activeLevel < LevelProgress.lastIndex else { return }
        activeLevel += 1
        resetRecording()
        viewModel.restart(difficulty: difficulty, level: activeLevel)
    }

    private func resetRecording() {
        recordedOutcome = false
        snapshot = AchievementSnapshot(progress: progress)
    }
}
