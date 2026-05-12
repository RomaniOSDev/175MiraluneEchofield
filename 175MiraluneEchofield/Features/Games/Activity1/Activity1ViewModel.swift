//
//  Activity1ViewModel.swift
//  175MiraluneEchofield
//

import Combine
import Foundation

struct Activity1Slot: Identifiable, Equatable {
    let id = UUID()
    let symbolIndex: Int
    var isFaceUp: Bool
    var isMatched: Bool
}

final class Activity1ViewModel: ObservableObject {
    @Published private(set) var slots: [Activity1Slot?] = []
    @Published private(set) var rows: Int = 4
    @Published private(set) var columns: Int = 4
    @Published private(set) var moves: Int = 0
    @Published private(set) var matchedPairs: Int = 0
    @Published private(set) var pairTarget: Int = 0
    @Published var showResult: Bool = false
    @Published private(set) var resultSuccess: Bool = false
    @Published private(set) var resultStars: Int = 0
    @Published private(set) var elapsedSeconds: Int = 0

    private var firstSelection: Int?
    private var isResolvingMismatch = false
    private var startedAt = Date()
    private var lastSuccessfulMatchAt = Date()
    private var lastIdleSoundAt = Date.distantPast
    private var tickTimer: AnyCancellable?

    private var difficulty: DifficultyTier
    private var level: Int

    init(difficulty: DifficultyTier, level: Int) {
        self.difficulty = difficulty
        self.level = level
        configureGrid()
        rebuildBoard()
        startTicking()
    }

    deinit {
        tickTimer?.cancel()
    }

    func restart(difficulty: DifficultyTier, level: Int) {
        tickTimer?.cancel()
        self.difficulty = difficulty
        self.level = level
        configureGrid()
        rebuildBoard()
        startTicking()
    }

    private func configureGrid() {
        switch difficulty {
        case .easy:
            rows = 4
            columns = 4
        case .normal:
            rows = 6
            columns = 6
        case .hard:
            rows = 8
            columns = 8
        }
    }

    private func pairCount() -> Int {
        let capIndex = LevelProgress.lastIndex
        let clampedLevel = min(max(level, 0), capIndex)
        let capacity = max(rows * columns / 2, 1)
        let progress = capIndex > 0 ? Double(clampedLevel) / Double(capIndex) : 0
        let lo: Int
        let hi: Int
        switch difficulty {
        case .easy:
            lo = 4
            hi = min(8, capacity)
        case .normal:
            lo = 6
            hi = min(18, capacity)
        case .hard:
            lo = 8
            hi = min(32, capacity)
        }
        let span = max(0, hi - lo)
        let value = lo + Int((Double(span) * progress).rounded(.down))
        return max(2, min(hi, value))
    }

    private func rebuildBoard() {
        firstSelection = nil
        isResolvingMismatch = false
        moves = 0
        matchedPairs = 0
        showResult = false
        resultSuccess = false
        resultStars = 0
        startedAt = Date()
        lastSuccessfulMatchAt = startedAt
        lastIdleSoundAt = Date.distantPast
        elapsedSeconds = 0

        pairTarget = pairCount()
        let totalCells = rows * columns
        let usedCells = pairTarget * 2
        var buffer: [Activity1Slot] = []
        var symbol = 0
        while buffer.count < usedCells {
            buffer.append(Activity1Slot(symbolIndex: symbol, isFaceUp: false, isMatched: false))
            buffer.append(Activity1Slot(symbolIndex: symbol, isFaceUp: false, isMatched: false))
            symbol += 1
        }
        buffer.shuffle()

        var grid: [Activity1Slot?] = Array(repeating: nil, count: totalCells)
        for index in 0..<min(usedCells, totalCells) {
            grid[index] = buffer[index]
        }
        slots = grid
    }

    private func startTicking() {
        tickTimer?.cancel()
        tickTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.handleTick(at: date)
            }
    }

    private func handleTick(at date: Date) {
        guard !showResult else { return }
        elapsedSeconds = Int(date.timeIntervalSince(startedAt))

        let idle = date.timeIntervalSince(lastSuccessfulMatchAt)
        if idle > 90, idle < 200 {
            if date.timeIntervalSince(lastIdleSoundAt) > 30 {
                lastIdleSoundAt = date
                FeedbackEffects.playSystemSoundLowEfficiency()
            }
        }

        if idle >= 200 {
            triggerFailure()
        }
    }

    private func triggerFailure() {
        guard !showResult else { return }
        tickTimer?.cancel()
        resultSuccess = false
        resultStars = 0
        showResult = true
    }

    func handleTap(at index: Int) {
        guard !showResult, !isResolvingMismatch else { return }
        guard index >= 0, index < slots.count else { return }
        guard var card = slots[index], !card.isMatched else { return }
        if card.isFaceUp, firstSelection == nil {
            return
        }

        FeedbackEffects.majorAction()

        if let first = firstSelection {
            if first == index {
                return
            }

            card.isFaceUp = true
            slots[index] = card
            moves += 1

            if let a = slots[first], let b = slots[index], a.symbolIndex == b.symbolIndex {
                markMatched(first: first, second: index)
                firstSelection = nil
                checkWin()
            } else {
                isResolvingMismatch = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.flipDown(first: first, second: index)
                    self?.isResolvingMismatch = false
                    self?.firstSelection = nil
                }
            }
        } else {
            card.isFaceUp = true
            slots[index] = card
            firstSelection = index
        }
    }

    private func markMatched(first: Int, second: Int) {
        lastSuccessfulMatchAt = Date()
        if var a = slots[first] {
            a.isMatched = true
            a.isFaceUp = true
            slots[first] = a
        }
        if var b = slots[second] {
            b.isMatched = true
            b.isFaceUp = true
            slots[second] = b
        }
        matchedPairs += 1
    }

    private func flipDown(first: Int, second: Int) {
        if var a = slots[first], !a.isMatched {
            a.isFaceUp = false
            slots[first] = a
        }
        if var b = slots[second], !b.isMatched {
            b.isFaceUp = false
            slots[second] = b
        }
    }

    private func checkWin() {
        guard matchedPairs >= pairTarget else { return }
        tickTimer?.cancel()
        let elapsed = Date().timeIntervalSince(startedAt)
        let seconds = Int(elapsed.rounded(.down))
        let stars = Self.stars(for: difficulty, seconds: seconds)
        resultStars = stars
        resultSuccess = true
        showResult = true
    }

    static func stars(for difficulty: DifficultyTier, seconds: Int) -> Int {
        switch difficulty {
        case .easy, .normal, .hard:
            if seconds < 60 { return 3 }
            if seconds < 120 { return 2 }
            if seconds < 180 { return 1 }
            return 0
        }
    }

    func symbolName(for symbolIndex: Int) -> String {
        let palette = [
            "circle.fill", "triangle.fill", "diamond.fill", "square.fill",
            "seal.fill", "pentagon.fill", "hexagon.fill", "rhombus.fill",
            "capsule.fill", "oval.fill", "cloud.fill", "bolt.fill"
        ]
        let safeIndex = symbolIndex % palette.count
        return palette[safeIndex]
    }
}
