//
//  GameResultView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct GameResultView: View {
    let isSuccess: Bool
    let stars: Int
    let primaryMetricTitle: String
    let primaryMetricValue: String
    let showAchievementBanner: Bool
    let showNextLevel: Bool
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    @State private var visibleStars = 0
    @State private var bannerOffset: CGFloat = -260
    @State private var redFlashOpacity: Double = 0
    @State private var didFireAppearEffects = false

    var body: some View {
        ZStack {
            AppDepth.resultScrimGradient
                .ignoresSafeArea()

            if !isSuccess {
                Color.red.opacity(redFlashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: 20) {
                    if isSuccess {
                        starRow
                        Text(primaryMetricTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        Text(primaryMetricValue)
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    } else {
                        Text("Keep Going")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Use Try Again when you are ready.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        if isSuccess, showNextLevel {
                            AppPrimaryButton(title: "Next Level") {
                                FeedbackEffects.majorAction()
                                onNextLevel()
                            }
                        }
                        AppPrimaryButton(title: "Try Again") {
                            FeedbackEffects.majorAction()
                            onRetry()
                        }
                        AppPrimaryButton(title: "Back to Levels") {
                            FeedbackEffects.majorAction()
                            onBackToLevels()
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .frame(maxWidth: 520)
            }
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppDepth.cardFillGradientSoft)
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTextPrimary.opacity(0.1), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 48)
                            .allowsHitTesting(false)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(AppDepth.cardBorderGradient(accent: Color.appAccent.opacity(0.45)), lineWidth: 1)
                    }
            }
            .appDepthShadow(elevated: true)
            .padding(.horizontal, 20)

            if isSuccess, showAchievementBanner {
                achievementBanner
                    .offset(y: bannerOffset)
                    .padding(.top, 12)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .onAppear {
            guard !didFireAppearEffects else { return }
            didFireAppearEffects = true
            if isSuccess {
                FeedbackEffects.successComplete()
                FeedbackEffects.playSystemSoundSuccess()
                animateStars()
                withAnimation(.easeInOut(duration: 2)) {
                    bannerOffset = 0
                }
            } else {
                FeedbackEffects.failure()
                FeedbackEffects.playSystemSoundFail()
                withAnimation(.easeInOut(duration: 0.3)) {
                    redFlashOpacity = 0.6
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        redFlashOpacity = 0
                    }
                }
            }
        }
    }

    private var starRow: some View {
        HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { index in
                ZStack {
                    if index < stars {
                        Image(systemName: "star.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.appAccent)
                            .shadow(color: Color.appAccent.opacity(0.55), radius: index < visibleStars ? 7 : 0)
                            .scaleEffect(index < visibleStars ? 1 : 0.3)
                            .opacity(index < visibleStars ? 1 : 0.15)
                    } else {
                        Image(systemName: "star")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.appTextSecondary.opacity(0.55))
                    }
                }
                .frame(height: 52)
            }
        }
    }

    private var achievementBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.appPrimary)
            Text("New achievement unlocked")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(AppDepth.cardFillGradient)
                .overlay {
                    Capsule()
                        .strokeBorder(Color.appPrimary.opacity(0.55), lineWidth: 1)
                }
        }
        .appDepthShadow(elevated: false)
    }

    private func animateStars() {
        visibleStars = 0
        for index in 0..<min(stars, 3) {
            let delay = Double(index) * 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                    visibleStars = index + 1
                }
                FeedbackEffects.starEarned()
            }
        }
    }
}
