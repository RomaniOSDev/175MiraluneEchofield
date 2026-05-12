//
//  FeedbackEffects.swift
//  175MiraluneEchofield
//

import AudioToolbox
import UIKit

enum FeedbackEffects {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let notification = UINotificationFeedbackGenerator()

    static func buttonTap() {
        lightImpact.prepare()
        lightImpact.impactOccurred()
    }

    static func majorAction() {
        mediumImpact.prepare()
        mediumImpact.impactOccurred()
    }

    static func starEarned() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    static func failure() {
        notification.prepare()
        notification.notificationOccurred(.error)
    }

    static func successComplete() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    static func playSystemSoundSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playSystemSoundFail() {
        AudioServicesPlaySystemSound(1521)
    }

    static func playSystemSoundLowEfficiency() {
        AudioServicesPlaySystemSound(1104)
    }
}
