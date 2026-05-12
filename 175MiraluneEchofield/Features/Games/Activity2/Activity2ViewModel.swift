//
//  Activity2ViewModel.swift
//  175MiraluneEchofield
//

import Combine
import Foundation

struct Activity2Slot: Identifiable, Equatable {
    let id = UUID()
    let symbolIndex: Int
    var isFaceUp: Bool
    var isMatched: Bool
}

final class Activity2ViewModel: ObservableObject {
    @Published private(set) var slots: [Activity2Slot?] = []
    @Published private(set) var rows: Int = 4
    @Published private(set) var columns: Int = 4
    @Published private(set) var moves: Int = 0
    @Published private(set) var matchedPairs: Int = 0
    @Published private(set) var pairTarget: Int = 0
    @Published var showResult: Bool = false
    @Published private(set) var resultSuccess: Bool = false
    @Published private(set) var resultStars: Int = 0
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var dragTrail: [Int] = []

    private var startedAt = Date()
    private var lastProgressAt = Date()
    private var isResolving = false
    private var tickTimer: AnyCancellable?

    private var difficulty: DifficultyTier
    private var level: Int

    init(difficulty: DifficultyTier, level: Int) {
        self.difficulty = difficulty
        self.level = level
        configureBoard()
        rebuild()
        startTicking()
    }

    deinit {
        tickTimer?.cancel()
    }

    func restart(difficulty: DifficultyTier, level: Int) {
        tickTimer?.cancel()
        self.difficulty = difficulty
        self.level = level
        configureBoard()
        rebuild()
        startTicking()
    }

    private func configureBoard() {
        switch difficulty {
        case .easy:
            rows = 4
            columns = 4
        case .normal:
            rows = 4
            columns = 4
        case .hard:
            rows = 4
            columns = 5
        }
    }

    private func pairGoal() -> Int {
        let capIndex = LevelProgress.lastIndex
        let clamped = min(max(level, 0), capIndex)
        let progress = capIndex > 0 ? Double(clamped) / Double(capIndex) : 0
        let lo: Int
        let hi: Int
        switch difficulty {
        case .easy:
            lo = 3
            hi = 6
        case .normal:
            lo = 5
            hi = 8
        case .hard:
            lo = 6
            hi = 10
        }
        let span = max(0, hi - lo)
        return max(2, lo + Int((Double(span) * progress).rounded(.down)))
    }

    private func rebuild() {
        moves = 0
        matchedPairs = 0
        dragTrail = []
        showResult = false
        resultSuccess = false
        resultStars = 0
        startedAt = Date()
        lastProgressAt = startedAt
        elapsedSeconds = 0
        isResolving = false

        pairTarget = pairGoal()
        let totalCells = rows * columns
        let used = min(pairTarget * 2, totalCells)
        pairTarget = used / 2

        slots = Self.buildGrid(rows: rows, columns: columns, pairCount: pairTarget)
    }

    /// Every pair occupies one grid edge so it can always be cleared with one adjacent swipe.
    private static func buildGrid(rows: Int, columns: Int, pairCount: Int) -> [Activity2Slot?] {
        for _ in 0..<240 {
            if let grid = tryPlaceAdjacentPairs(rows: rows, columns: columns, pairCount: pairCount) {
                return grid
            }
        }
        return fallbackAdjacentPairs(rows: rows, columns: columns, pairCount: pairCount)
    }

    private static func tryPlaceAdjacentPairs(rows: Int, columns: Int, pairCount: Int) -> [Activity2Slot?]? {
        let totalCells = rows * columns
        var grid: [Activity2Slot?] = Array(repeating: nil, count: totalCells)
        var edges = adjacentEdges(rows: rows, columns: columns)
        edges.shuffle()
        var placed = 0
        while placed < pairCount {
            guard let index = edges.firstIndex(where: { edge in
                grid[edge.0] == nil && grid[edge.1] == nil
            }) else {
                return nil
            }
            let edge = edges.remove(at: index)
            let slotA = Activity2Slot(symbolIndex: placed, isFaceUp: false, isMatched: false)
            let slotB = Activity2Slot(symbolIndex: placed, isFaceUp: false, isMatched: false)
            grid[edge.0] = slotA
            grid[edge.1] = slotB
            placed += 1
        }
        return grid
    }

    private static func fallbackAdjacentPairs(rows: Int, columns: Int, pairCount: Int) -> [Activity2Slot?] {
        let totalCells = rows * columns
        var grid: [Activity2Slot?] = Array(repeating: nil, count: totalCells)
        var edges = adjacentEdges(rows: rows, columns: columns)
        var placed = 0
        while placed < pairCount {
            guard let index = edges.firstIndex(where: { edge in
                grid[edge.0] == nil && grid[edge.1] == nil
            }) else {
                break
            }
            let edge = edges.remove(at: index)
            grid[edge.0] = Activity2Slot(symbolIndex: placed, isFaceUp: false, isMatched: false)
            grid[edge.1] = Activity2Slot(symbolIndex: placed, isFaceUp: false, isMatched: false)
            placed += 1
        }
        if placed < pairCount {
            return rowDominoFallback(rows: rows, columns: columns, pairCount: pairCount)
        }
        return grid
    }

    /// Guaranteed layout: greedy placement along edges in stable order (always succeeds on grid graphs used here).
    private static func rowDominoFallback(rows: Int, columns: Int, pairCount: Int) -> [Activity2Slot?] {
        let totalCells = rows * columns
        var grid: [Activity2Slot?] = Array(repeating: nil, count: totalCells)
        let edges = adjacentEdges(rows: rows, columns: columns).sorted {
            if $0.0 != $1.0 { return $0.0 < $1.0 }
            return $0.1 < $1.1
        }
        var symbol = 0
        for edge in edges {
            guard symbol < pairCount else { break }
            if grid[edge.0] == nil, grid[edge.1] == nil {
                let a = Activity2Slot(symbolIndex: symbol, isFaceUp: false, isMatched: false)
                let b = Activity2Slot(symbolIndex: symbol, isFaceUp: false, isMatched: false)
                grid[edge.0] = a
                grid[edge.1] = b
                symbol += 1
            }
        }
        return grid
    }

    private static func adjacentEdges(rows: Int, columns: Int) -> [(Int, Int)] {
        var edges: [(Int, Int)] = []
        for row in 0..<rows {
            for col in 0..<columns {
                let index = row * columns + col
                if col + 1 < columns {
                    let right = index + 1
                    edges.append(index < right ? (index, right) : (right, index))
                }
                if row + 1 < rows {
                    let down = index + columns
                    edges.append(index < down ? (index, down) : (down, index))
                }
            }
        }
        return edges
    }

    private func startTicking() {
        tickTimer?.cancel()
        tickTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.handleTick(date)
            }
    }

    private func handleTick(_ date: Date) {
        guard !showResult else { return }
        elapsedSeconds = Int(date.timeIntervalSince(startedAt))
        let idle = date.timeIntervalSince(lastProgressAt)
        if idle > 240 {
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

    func updateDrag(location: CGPoint, in size: CGSize, phase: DragPhase) {
        guard !showResult, !isResolving else { return }
        switch phase {
        case .began:
            dragTrail.removeAll()
            if let index = index(for: location, in: size) {
                dragTrail.append(index)
            }
        case .changed:
            guard let index = index(for: location, in: size) else { return }
            if let last = dragTrail.last, last == index { return }
            if dragTrail.count >= 2 { return }
            if dragTrail.isEmpty {
                dragTrail.append(index)
                return
            }
            if let last = dragTrail.last, isAdjacent(last, index) {
                dragTrail.append(index)
            }
        case .ended:
            finalizeSwipe()
        case .cancelled:
            dragTrail.removeAll()
        }
    }

    enum DragPhase {
        case began
        case changed
        case ended
        case cancelled
    }

    private func finalizeSwipe() {
        let unique = uniqueOrderedIndices(from: dragTrail)
        dragTrail.removeAll()
        guard unique.count >= 2 else { return }
        let first = unique[0]
        let second = unique[1]
        revealAndResolve(first: first, second: second)
    }

    private func uniqueOrderedIndices(from path: [Int]) -> [Int] {
        var result: [Int] = []
        for value in path {
            if result.last == value { continue }
            result.append(value)
            if result.count == 2 { break }
        }
        return result
    }

    private func isAdjacent(_ a: Int, _ b: Int) -> Bool {
        let ar = a / columns
        let ac = a % columns
        let br = b / columns
        let bc = b % columns
        let dr = abs(ar - br)
        let dc = abs(ac - bc)
        return (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
    }

    private func index(for point: CGPoint, in size: CGSize) -> Int? {
        guard columns > 0, rows > 0 else { return nil }
        let cellWidth = size.width / CGFloat(columns)
        let cellHeight = size.height / CGFloat(rows)
        guard cellWidth > 0, cellHeight > 0 else { return nil }
        let column = Int(point.x / cellWidth)
        let row = Int(point.y / cellHeight)
        guard column >= 0, column < columns, row >= 0, row < rows else { return nil }
        return row * columns + column
    }

    private func revealAndResolve(first: Int, second: Int) {
        guard var a = slots[first], var b = slots[second], !a.isMatched, !b.isMatched else { return }
        FeedbackEffects.majorAction()
        a.isFaceUp = true
        b.isFaceUp = true
        slots[first] = a
        slots[second] = b
        moves += 1

        if a.symbolIndex == b.symbolIndex {
            a.isMatched = true
            b.isMatched = true
            slots[first] = a
            slots[second] = b
            matchedPairs += 1
            lastProgressAt = Date()
            checkWin()
        } else {
            isResolving = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                self?.flipDown(first: first, second: second)
                self?.isResolving = false
            }
        }
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
        let seconds = Int(Date().timeIntervalSince(startedAt).rounded(.down))
        resultStars = Self.stars(seconds: seconds)
        resultSuccess = true
        showResult = true
    }

    static func stars(seconds: Int) -> Int {
        if seconds < 60 { return 3 }
        if seconds < 90 { return 2 }
        if seconds < 120 { return 1 }
        return 0
    }

    func symbolName(for symbolIndex: Int) -> String {
        let palette = [
            "sun.max.fill", "moon.fill", "leaf.fill", "flame.fill",
            "drop.fill", "snowflake", "hurricane", "tornado",
            "sparkle", "wind", "cloud.rain.fill", "cloud.bolt.fill"
        ]
        return palette[symbolIndex % palette.count]
    }
}
