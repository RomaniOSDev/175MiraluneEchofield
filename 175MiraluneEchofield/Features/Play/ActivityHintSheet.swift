//
//  ActivityHintSheet.swift
//  175MiraluneEchofield
//

import SwiftUI

struct ActivityHintSheet: View {
    let activity: ActivityIdentifier
    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private var title: String {
        switch activity {
        case .pairTiles: return "How Pair Tiles works"
        case .mysticSwipe: return "How Mystic Swipe works"
        case .rhythmDuel: return "How RhythmMatch works"
        }
    }

    private var bullets: [String] {
        switch activity {
        case .pairTiles:
            return [
                "Tap two tiles to flip them face up.",
                "Matching pairs stay revealed; others flip back after a moment.",
                "Clear the board with as few moves as you can."
            ]
        case .mysticSwipe:
            return [
                "Drag in one stroke across two neighboring tiles.",
                "Only side-by-side tiles count — horizontal or vertical.",
                "Each matching pair sits next to its twin on the grid."
            ]
        case .rhythmDuel:
            return [
                "Press and hold until the ring fills, then release to lock a tile.",
                "Match two identical tiles within a few seconds.",
                "On Hard mode, ignore the decoy tiles that cannot be paired."
            ]
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(bullets.enumerated()), id: \.offset) { _, line in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(Color.appPrimary)
                                .padding(.top, 6)
                            Text(line)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.appTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .appCardDepth(cornerRadius: 14, elevated: false, accentEdge: Color.appAccent.opacity(0.25), rimLight: true)
                    }
                }
                .padding(20)
            }
            .background(AppDepth.sheetBackdropGradient.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Got it") {
                        FeedbackEffects.majorAction()
                        progress.markActivityHintSeen(activity)
                        dismiss()
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}
