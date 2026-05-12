//
//  Activity3ViewModel.swift
//  175MiraluneEchofield
//

import Combine
import Foundation

struct Activity3Slot: Identifiable, Equatable {
    let id = UUID()
    let symbolIndex: Int
    let isDecoy: Bool
    var isFaceUp: Bool
    var isMatched: Bool
}

final class Activity3ViewModel: ObservableObject {
    @Published private(set) var slots: [Activity3Slot?] = []
    @Published private(set) var rows: Int = 4
    @Published private(set) var columns: Int = 4
    @Published private(set) var moves: Int = 0
    @Published private(set) var matchedPairs: Int = 0
    @Published private(set) var pairTarget: Int = 8
    @Published private(set) var wrongMatches: Int = 0
    @Published private(set) var pressProgress: [Int: Double] = [:]
    @Published var showResult: Bool = false
    @Published private(set) var resultSuccess: Bool = false
    @Published private(set) var resultStars: Int = 0
    @Published private(set) var elapsedSeconds: Int = 0

    @Published private(set) var isPreviewing = false

    private var startedAt = Date()
    private var tickTimer: AnyCancellable?
    private var pressTimer: AnyCancellable?
    private var firstLockResetWorkItem: DispatchWorkItem?

    private var activePressIndex: Int?
    private var pressBeganAt: Date?
    private var firstLockedIndex: Int?
    private var firstLockedAt: Date?

    private var difficulty: DifficultyTier
    private var level: Int

    init(difficulty: DifficultyTier, level: Int) {
        self.difficulty = difficulty
        self.level = level
        configureGrid()
        rebuild()
        startTicking()
    }

    deinit {
        tickTimer?.cancel()
        pressTimer?.cancel()
        firstLockResetWorkItem?.cancel()
    }

    func restart(difficulty: DifficultyTier, level: Int) {
        tickTimer?.cancel()
        pressTimer?.cancel()
        firstLockResetWorkItem?.cancel()
        self.difficulty = difficulty
        self.level = level
        configureGrid()
        rebuild()
        startTicking()
    }

    private func configureGrid() {
        switch difficulty {
        case .easy, .normal:
            rows = 4
            columns = 4
        case .hard:
            rows = 4
            columns = 5
        }
    }

    private func rebuild() {
        moves = 0
        matchedPairs = 0
        wrongMatches = 0
        showResult = false
        resultSuccess = false
        resultStars = 0
        startedAt = Date()
        elapsedSeconds = 0
        pressProgress.removeAll()
        activePressIndex = nil
        pressBeganAt = nil
        firstLockedIndex = nil
        firstLockedAt = nil
        pairTarget = 8

        var buffer: [Activity3Slot] = []
        for symbol in 0..<pairTarget {
            buffer.append(Activity3Slot(symbolIndex: symbol, isDecoy: false, isFaceUp: false, isMatched: false))
            buffer.append(Activity3Slot(symbolIndex: symbol, isDecoy: false, isFaceUp: false, isMatched: false))
        }

        if difficulty == .hard {
            buffer.append(Activity3Slot(symbolIndex: 900, isDecoy: true, isFaceUp: false, isMatched: false))
            buffer.append(Activity3Slot(symbolIndex: 900, isDecoy: true, isFaceUp: false, isMatched: false))
            let lateHard = level >= (LevelProgress.lastIndex + 1) / 2
            if lateHard {
                buffer.append(Activity3Slot(symbolIndex: 901, isDecoy: true, isFaceUp: false, isMatched: false))
                buffer.append(Activity3Slot(symbolIndex: 901, isDecoy: true, isFaceUp: false, isMatched: false))
            }
        }

        buffer.shuffle()

        let totalCells = rows * columns
        var grid: [Activity3Slot?] = Array(repeating: nil, count: totalCells)
        for index in 0..<min(buffer.count, totalCells) {
            grid[index] = buffer[index]
        }
        slots = grid

        if difficulty == .easy {
            isPreviewing = true
            flipAll(show: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.isPreviewing = false
                self?.flipAll(show: false)
                self?.startedAt = Date()
            }
        } else {
            isPreviewing = false
        }
    }

    private func flipAll(show: Bool) {
        var updated = slots
        for index in updated.indices {
            if var slot = updated[index], !slot.isMatched {
                slot.isFaceUp = show
                updated[index] = slot
            }
        }
        slots = updated
    }

    private func startTicking() {
        tickTimer?.cancel()
        tickTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                guard let self else { return }
                self.elapsedSeconds = Int(date.timeIntervalSince(self.startedAt))
            }
    }

    func touchDown(on index: Int) {
        guard !showResult else { return }
        guard isPreviewing == false else { return }
        guard let slot = slots[index], !slot.isMatched else { return }
        if slot.isFaceUp {
            return
        }
        if activePressIndex == nil {
            activePressIndex = index
            pressBeganAt = Date()
            startPressTimer()
        }
    }

    func touchUp(on index: Int) {
        guard activePressIndex == index else { return }
        pressTimer?.cancel()
        let progress = pressProgress[index] ?? 0
        activePressIndex = nil
        pressBeganAt = nil
        pressProgress[index] = 0

        if progress < 0.999 {
            FeedbackEffects.buttonTap()
            return
        }

        FeedbackEffects.majorAction()
        lockCard(at: index)
    }

    private func startPressTimer() {
        pressTimer?.cancel()
        pressTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.updatePressProgress(at: date)
            }
    }

    private func updatePressProgress(at date: Date) {
        guard let index = activePressIndex, let began = pressBeganAt else { return }
        let elapsed = date.timeIntervalSince(began)
        if elapsed < 0.3 {
            pressProgress[index] = 0
            return
        }
        let hold = elapsed - 0.3
        let value = min(1, hold / 2.0)
        pressProgress[index] = value
    }

    private func lockCard(at index: Int) {
        guard var slot = slots[index] else { return }
        slot.isFaceUp = true
        slots[index] = slot

        if let first = firstLockedIndex, let lockTime = firstLockedAt {
            firstLockResetWorkItem?.cancel()
            let delta = Date().timeIntervalSince(lockTime)
            if delta > 5 {
                firstLockResetWorkItem?.cancel()
                flipDown(first: first, second: index)
                firstLockedIndex = nil
                firstLockedAt = nil
                FeedbackEffects.playSystemSoundFail()
                return
            }

            if let a = slots[first], let b = slots[index],
               a.symbolIndex == b.symbolIndex, !a.isDecoy, !b.isDecoy {
                markMatched(first: first, second: index)
            } else {
                registerWrongMatch(first: first, second: index)
            }
            firstLockedIndex = nil
            firstLockedAt = nil
        } else {
            firstLockedIndex = index
            firstLockedAt = Date()
            moves += 1
            scheduleFirstLockTimeout(for: index)
        }
    }

    private func scheduleFirstLockTimeout(for index: Int) {
        firstLockResetWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.firstLockedIndex == index else { return }
            self.flipDownSingle(index)
            self.firstLockedIndex = nil
            self.firstLockedAt = nil
            FeedbackEffects.playSystemSoundFail()
        }
        firstLockResetWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: work)
    }

    private func flipDownSingle(_ index: Int) {
        if var slot = slots[index], !slot.isMatched {
            slot.isFaceUp = false
            slots[index] = slot
        }
    }

    private func registerWrongMatch(first: Int, second: Int) {
        firstLockResetWorkItem?.cancel()
        FeedbackEffects.playSystemSoundFail()
        wrongMatches += 1
        flipDown(first: first, second: second)
        if wrongMatches > 3 {
            triggerFailure()
        }
    }

    private func markMatched(first: Int, second: Int) {
        firstLockResetWorkItem?.cancel()
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
        checkWin()
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
        pressTimer?.cancel()
        firstLockResetWorkItem?.cancel()
        let seconds = Int(Date().timeIntervalSince(startedAt).rounded(.down))
        resultStars = Self.stars(seconds: seconds)
        resultSuccess = true
        showResult = true
    }

    private func triggerFailure() {
        guard !showResult else { return }
        tickTimer?.cancel()
        pressTimer?.cancel()
        firstLockResetWorkItem?.cancel()
        resultSuccess = false
        resultStars = 0
        showResult = true
    }

    static func stars(seconds: Int) -> Int {
        if seconds < 30 { return 3 }
        if seconds < 45 { return 2 }
        if seconds < 60 { return 1 }
        return 0
    }

    func symbolName(for symbolIndex: Int) -> String {
        if symbolIndex == 900 {
            return "questionmark"
        }
        if symbolIndex == 901 {
            return "xmark.octagon.fill"
        }
        let palette = [
            "circle.grid.cross.fill", "square.grid.3x3.fill", "triangle.fill",
            "diamond.fill", "hexagon.fill", "octagon.fill", "star.fill", "heart.fill"
        ]
        return palette[symbolIndex % palette.count]
    }
}
