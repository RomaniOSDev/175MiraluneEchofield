//
//  MainTabView.swift
//  175MiraluneEchofield
//

import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case play
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .play: return "Play"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .play: return "play.circle.fill"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @State private var tab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .home:
                    NavigationStack {
                        HomeView(selectedMainTab: $tab)
                    }
                case .play:
                    NavigationStack {
                        PlayTabView()
                    }
                case .achievements:
                    NavigationStack {
                        AchievementsView()
                    }
                case .settings:
                    NavigationStack {
                        SettingsView()
                    }
                }
            }
            .padding(.bottom, 72)

            customTabBar
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
        }
        .background(LayeredBackground())
    }

    private var customTabBar: some View {
        HStack(spacing: 10) {
            ForEach(MainTab.allCases, id: \.rawValue) { item in
                Button {
                    FeedbackEffects.buttonTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        tab = item
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 20, weight: .semibold))
                        Text(item.title)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(tab == item ? Color.appBackground : Color.appTextPrimary.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if tab == item {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppDepth.primaryControlGradient)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(Color.appTextPrimary.opacity(0.18), lineWidth: 1)
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppDepth.cardFillGradientSoft)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(AppDepth.cardBorderGradient(accent: nil), lineWidth: 1)
                                }
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .frame(minHeight: 44)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.95),
                            Color.appSurface.opacity(0.72),
                            Color.appPrimary.opacity(0.06),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(AppDepth.cardBorderGradient(accent: Color.appAccent.opacity(0.28)), lineWidth: 1)
                }
        }
        .appDepthShadow(elevated: true)
    }
}
