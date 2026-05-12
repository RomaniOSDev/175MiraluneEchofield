//
//  ContentView.swift
//  175MiraluneEchofield
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progress = ProgressStore()

    var body: some View {
        Group {
            if progress.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(progress)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
