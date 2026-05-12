//
//  OnboardingView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var pageIndex = 0

    private let pages: [(title: String, detail: String)] = [
        ("Tap to play", "Tap a card to reveal its face. Find pairs across the board."),
        ("Match for stars", "Clear the grid with sharp focus — every solid run earns up to three stars."),
        ("Begin your path", "Unlock stages, chase the weekly goal, and try today’s spotlight when you are ready."),
    ]

    var body: some View {
        ZStack {
            LayeredBackground()
            VStack(spacing: 0) {
                headerChrome
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 6)

                TabView(selection: $pageIndex) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(
                            stepIndex: index,
                            pageCount: pages.count,
                            activeStep: pageIndex,
                            title: pages[index].title,
                            detail: pages[index].detail,
                            illustration: illustration(for: index)
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.34), value: pageIndex)

                bottomChrome
            }
        }
    }

    private var headerChrome: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppDepth.primaryControlGradient)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.14), lineWidth: 1)
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTextPrimary.opacity(0.14), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 22)
                            .allowsHitTesting(false)
                    }
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.appBackground)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Your training floor")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer(minLength: 0)

            Text("\(pageIndex + 1)/\(pages.count)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color.appBackground)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background {
                    Capsule()
                        .fill(AppDepth.pillGradient)
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                        }
                }
        }
        .padding(16)
        .appCardDepth(
            cornerRadius: 20,
            elevated: false,
            accentEdge: Color.appAccent.opacity(0.32),
            rimLight: true
        )
    }

    private var bottomChrome: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { dot in
                    OnboardingProgressDot(isSelected: dot == pageIndex)
                        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: pageIndex)
                }
            }

            AppPrimaryButton(title: pageIndex == pages.count - 1 ? "Get Started" : "Next") {
                FeedbackEffects.majorAction()
                if pageIndex == pages.count - 1 {
                    progress.markOnboardingSeen()
                } else {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        pageIndex += 1
                    }
                }
            }
        }
        .padding(20)
        .appCardDepth(
            cornerRadius: 22,
            elevated: true,
            accentEdge: Color.appAccent.opacity(0.38),
            rimLight: true
        )
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 28)
    }

    @ViewBuilder
    private func illustration(for index: Int) -> some View {
        switch index {
        case 0:
            OnboardingIllustrationTap()
        case 1:
            OnboardingIllustrationStars()
        default:
            OnboardingIllustrationQuest()
        }
    }
}

// MARK: - Progress dot

private struct OnboardingProgressDot: View {
    let isSelected: Bool

    var body: some View {
        Group {
            if isSelected {
                Capsule()
                    .fill(AppDepth.primaryControlGradient)
                    .frame(width: 32, height: 10)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.appTextPrimary.opacity(0.14), lineWidth: 1)
                    )
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTextPrimary.opacity(0.12), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 6)
                            .padding(.horizontal, 4)
                            .allowsHitTesting(false)
                    }
            } else {
                Circle()
                    .fill(AppDepth.cardFillGradientSoft)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .strokeBorder(AppDepth.cardBorderGradient(accent: nil), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Page

private struct OnboardingPageView<Illustration: View>: View {
    let stepIndex: Int
    let pageCount: Int
    let activeStep: Int
    let title: String
    let detail: String
    let illustration: Illustration

    private var isActive: Bool { activeStep == stepIndex }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    illustration
                        .frame(height: 268)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 14)
                        .background {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.appPrimary.opacity(0.24),
                                            Color.appSurface.opacity(0.74),
                                            Color.appAccent.opacity(0.1),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.appTextPrimary.opacity(0.12), Color.clear],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(height: 76)
                                        .allowsHitTesting(false)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .strokeBorder(
                                            AppDepth.cardBorderGradient(accent: Color.appAccent.opacity(0.38)),
                                            lineWidth: 1
                                        )
                                }
                        }
                        .appDepthShadow(elevated: true)
                }
                .scaleEffect(isActive ? 1 : 0.93)
                .opacity(isActive ? 1 : 0.42)
                .animation(.spring(response: 0.46, dampingFraction: 0.74), value: activeStep)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Step \(stepIndex + 1) of \(pageCount)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.appAccent)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .background {
                            Capsule()
                                .fill(AppDepth.cardFillGradientSoft)
                                .overlay {
                                    Capsule()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.appAccent.opacity(0.45),
                                                    Color.appPrimary.opacity(0.2),
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                        }

                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(detail)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .appCardDepth(
                    cornerRadius: 20,
                    elevated: false,
                    accentEdge: Color.appPrimary.opacity(0.28),
                    rimLight: true
                )
                .padding(.horizontal, 18)
                .scaleEffect(isActive ? 1 : 0.96)
                .opacity(isActive ? 1 : 0.45)
                .offset(y: isActive ? 0 : 8)
                .animation(.spring(response: 0.44, dampingFraction: 0.78), value: activeStep)
            }
            .padding(.vertical, 28)
        }
    }
}

// MARK: - Illustrations

private struct OnboardingIllustrationTap: View {
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    miniTile(faceUp: false)
                    miniTile(faceUp: true, symbol: "moon.stars.fill")
                }
                HStack(spacing: 10) {
                    miniTile(faceUp: true, symbol: "leaf.fill")
                    miniTile(faceUp: false)
                }
            }

            Image(systemName: "hand.tap.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .offset(x: 56, y: 44)
                .shadow(color: Color.appAccent.opacity(0.32), radius: 4, y: 2)
        }
    }

    private func miniTile(faceUp: Bool, symbol: String = "") -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    faceUp
                        ? AppDepth.gameTileFaceGradient
                        : LinearGradient(
                            colors: [Color.appPrimary.opacity(0.58), Color.appPrimary.opacity(0.28)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .frame(width: 72, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            Color.appPrimary.opacity(faceUp ? 0.45 : 0.25),
                            lineWidth: 1
                        )
                )
                .overlay(alignment: .top) {
                    if faceUp {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTextPrimary.opacity(0.12), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 22)
                            .allowsHitTesting(false)
                    }
                }
            if faceUp {
                Image(systemName: symbol)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.appAccent)
            }
        }
    }
}

private struct OnboardingIllustrationStars: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppDepth.cardFillGradient)
                .frame(width: 200, height: 120)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appTextPrimary.opacity(0.1), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 40)
                        .allowsHitTesting(false)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(AppDepth.cardBorderGradient(accent: Color.appAccent.opacity(0.42)), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 8) {
                        Text("Results")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color.appTextSecondary)
                        Text("· up to 3★")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                    }
                    .padding(14)
                }
                .offset(y: 56)
                .appDepthShadow(elevated: false)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary.opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color.appAccent.opacity(0.35), radius: 4, y: 2)
                        .offset(y: i == 1 ? -16 : 0)
                }
            }
            .offset(y: -12)
        }
    }
}

private struct OnboardingIllustrationQuest: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.52),
                            Color.appPrimary.opacity(0.14),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 260, height: 96)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appTextPrimary.opacity(0.08), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 28)
                        .allowsHitTesting(false)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(AppDepth.cardBorderGradient(accent: Color.appPrimary.opacity(0.38)), lineWidth: 1)
                )

            HStack(alignment: .center, spacing: 14) {
                questTile(height: 64)
                questTile(height: 80)
                questTile(height: 64)
            }

            Image(systemName: "arrow.forward.circle.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .offset(x: 118, y: -58)
        }
    }

    private func questTile(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(AppDepth.gameTileFaceGradient)
            .frame(width: 52, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(AppDepth.cardBorderGradient(accent: Color.appAccent.opacity(0.32)), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appTextPrimary.opacity(0.1), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 18)
                    .allowsHitTesting(false)
            }
    }
}
