//
//  SettingsView.swift
//  175MiraluneEchofield
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var showResetAlert = false

    private var versionString: String {
        let value = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        if let string = value as? String {
            return string
        }
        return "1.0"
    }

    var body: some View {
        ZStack {
            LayeredBackground()
            ScrollView {
                VStack(spacing: 16) {
                    statsCard

                    settingsRow(title: "Rate us", symbol: "star.circle.fill") {
                        FeedbackEffects.buttonTap()
                        rateApp()
                    }

                    settingsRow(title: "Privacy Policy", symbol: "hand.raised.fill") {
                        FeedbackEffects.buttonTap()
                        openPolicyURL()
                    }

                    settingsRow(title: "Terms of Use", symbol: "doc.plaintext.fill") {
                        FeedbackEffects.buttonTap()
                        openTermsURL()
                    }

                    settingsRow(title: "Support", symbol: "envelope.fill") {
                        FeedbackEffects.buttonTap()
                        openSupportEmail()
                    }

                    AppPrimaryButton(title: "Reset All Progress", role: .destructive) {
                        FeedbackEffects.buttonTap()
                        showResetAlert = true
                    }

                    Text("Version \(versionString)")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(AppDepth.navigationBarFill, for: .navigationBar)
        .alert("Reset All Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {
                FeedbackEffects.buttonTap()
            }
            Button("Reset", role: .destructive) {
                FeedbackEffects.majorAction()
                progress.resetAllProgress()
            }
        } message: {
            Text("This clears every saved star, level unlock, and statistic on this device.")
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            statRow(title: "Activities played", value: "\(progress.totalActivitiesPlayed)")
            statRow(title: "Stars earned", value: "\(progress.totalStarsEarned)")
            statRow(title: "Total play time", value: progress.formattedPlayTime())
            weeklyGoalSection
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardDepth(cornerRadius: 18, elevated: true, accentEdge: Color.appPrimary.opacity(0.35), rimLight: true)
    }

    private var weeklyGoalSection: some View {
        let target = ProgressStore.weeklyStarTarget
        let earned = progress.weeklyStarsEarned
        let fraction = min(1, Double(earned) / Double(max(target, 1)))
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("This week's stars")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(earned) / \(target)")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appSurface.opacity(0.6))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.35), Color.appAccent.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * fraction))
                }
            }
            .frame(height: 10)
            Text("Resets every calendar week. Earn stars in any stage that counts toward progress.")
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.appTextSecondary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private func settingsRow(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 36, height: 36)
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 44)
            .appCardDepth(cornerRadius: 16, elevated: false, accentEdge: nil)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func openSupportEmail() {
        guard let url = URL(string: "mailto:support@example.com") else { return }
        UIApplication.shared.open(url)
    }

    private func openPolicyURL() {
        if let url = URL(string: AppExternalLink.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsURL() {
        if let url = URL(string: AppExternalLink.termsOfUse.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
