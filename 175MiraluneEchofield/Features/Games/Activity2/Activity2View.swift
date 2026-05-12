//
//  Activity2View.swift
//  175MiraluneEchofield
//

import SwiftUI

struct Activity2View: View {
    let difficulty: DifficultyTier
    let isPractice: Bool
    let isDailySpotlight: Bool

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: Activity2ViewModel
    @State private var activeLevel: Int
    @State private var recordedOutcome = false
    @State private var snapshot: AchievementSnapshot?
    @State private var dragSessionActive = false

    init(difficulty: DifficultyTier, level: Int, isPractice: Bool = false, isDailySpotlight: Bool = false) {
        self.difficulty = difficulty
        self.isPractice = isPractice
        self.isDailySpotlight = isDailySpotlight
        _activeLevel = State(initialValue: level)
        _viewModel = StateObject(wrappedValue: Activity2ViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    statsHeader
                    board
                        .padding(10)
                        .appCardDepth(cornerRadius: 20, elevated: false, accentEdge: Color.appPrimary.opacity(0.12))
                    Text("Drag across two neighboring tiles in one stroke.")
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
                    primaryMetricTitle: "Swipes",
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
        .navigationTitle("Mystic Swipe Match")
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
                    activity: .mysticSwipe,
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
                    activity: .mysticSwipe,
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
                Text("Swipes \(viewModel.moves)")
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

            ZStack {
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

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if dragSessionActive == false {
                                    dragSessionActive = true
                                    viewModel.updateDrag(location: value.location, in: geo.size, phase: .began)
                                } else {
                                    viewModel.updateDrag(location: value.location, in: geo.size, phase: .changed)
                                }
                            }
                            .onEnded { value in
                                if dragSessionActive == false {
                                    viewModel.updateDrag(location: value.startLocation, in: geo.size, phase: .began)
                                }
                                viewModel.updateDrag(location: value.location, in: geo.size, phase: .ended)
                                dragSessionActive = false
                            }
                    )
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
                if card.isFaceUp || card.isMatched {
                    Image(systemName: viewModel.symbolName(for: card.symbolIndex))
                        .font(.system(size: size.width * 0.36, weight: .bold))
                        .foregroundStyle(Color.appAccent)
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.35))
                        .padding(8)
                }
            }
            .frame(width: size.width, height: size.height)
            .allowsHitTesting(false)
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
