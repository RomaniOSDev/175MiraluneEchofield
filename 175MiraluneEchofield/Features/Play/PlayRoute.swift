//
//  PlayRoute.swift
//  175MiraluneEchofield
//

import SwiftUI

enum PlayRoute: Hashable {
    case browse(ActivityIdentifier)
    case practice(ActivityIdentifier)
    case dailySpotlight
}

struct PlayRouteDestinationView: View {
    let route: PlayRoute

    var body: some View {
        switch route {
        case .browse(let activity):
            ActivitySelectionView(activity: activity, practiceMode: false)
        case .practice(let activity):
            ActivitySelectionView(activity: activity, practiceMode: true)
        case .dailySpotlight:
            DailySpotlightHostView()
        }
    }
}
