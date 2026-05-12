//
//  LevelStageCell.swift
//  175MiraluneEchofield
//

import SwiftUI

struct LevelStageCell: View {
    let levelNumber: Int
    let stars: Int
    let locked: Bool
    var bestSubtitle: String?

    private var isPerfect: Bool {
        !locked && stars >= 3
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cellFill)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(borderGradient, lineWidth: locked ? 1.2 : isPerfect ? 2.2 : 1.8)

            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(badgeFill)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle()
                                    .stroke(Color.appPrimary.opacity(locked ? 0.12 : 0.45), lineWidth: 1.5)
                            )

                        Text("\(levelNumber)")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(locked ? Color.appTextSecondary.opacity(0.75) : Color.appTextPrimary)
                    }

                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(Color.appSurface.opacity(0.95))
                                    .overlay(Circle().stroke(Color.appTextSecondary.opacity(0.35), lineWidth: 1))
                            )
                            .offset(x: 6, y: -6)
                    }
                }

                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { starIndex in
                        Image(systemName: starIndex < stars ? "star.fill" : "star")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(starColor(filled: starIndex < stars))
                            .scaleEffect(starIndex < stars ? 1 : 0.92)
                    }
                }
                .padding(.horizontal, 4)

                if let bestSubtitle, !bestSubtitle.isEmpty, !locked {
                    Text(bestSubtitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }

                Text(locked ? "Locked" : "Play")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(locked ? Color.appTextSecondary.opacity(0.8) : Color.appPrimary)
                    .tracking(0.6)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: bestSubtitle == nil || locked ? 132 : 148)
        .opacity(locked ? 0.72 : 1)
        .scaleEffect(locked ? 0.98 : 1)
        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: locked)
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: stars)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Level \(levelNumber)")
        .accessibilityValue(locked ? "Locked" : "\(stars) of 3 stars")
    }

    private var cellFill: LinearGradient {
        if locked {
            return LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.45),
                    Color.appSurface.opacity(0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color.appSurface.opacity(0.96),
                Color.appSurface.opacity(0.68),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderGradient: LinearGradient {
        if locked {
            return LinearGradient(
                colors: [
                    Color.appTextSecondary.opacity(0.35),
                    Color.appTextSecondary.opacity(0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        if isPerfect {
            return LinearGradient(
                colors: [
                    Color.appAccent.opacity(0.95),
                    Color.appPrimary.opacity(0.85),
                    Color.appAccent.opacity(0.55),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color.appPrimary.opacity(0.55),
                Color.appPrimary.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var badgeFill: LinearGradient {
        if locked {
            return LinearGradient(
                colors: [
                    Color.appTextSecondary.opacity(0.12),
                    Color.appTextSecondary.opacity(0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        return LinearGradient(
            colors: [
                Color.appPrimary.opacity(0.35),
                Color.appPrimary.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func starColor(filled: Bool) -> Color {
        if locked {
            return Color.appTextSecondary.opacity(filled ? 0.45 : 0.28)
        }
        return filled ? Color.appAccent : Color.appTextSecondary.opacity(0.5)
    }
}
