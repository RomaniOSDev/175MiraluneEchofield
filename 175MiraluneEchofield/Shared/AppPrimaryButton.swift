//
//  AppPrimaryButton.swift
//  175MiraluneEchofield
//

import SwiftUI

struct AppPrimaryButton: View {
    let title: String
    var role: Role = .primary
    let action: () -> Void

    enum Role {
        case primary
        case destructive
    }

    var body: some View {
        Button {
            FeedbackEffects.buttonTap()
            action()
        } label: {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(role == .destructive ? Color.appTextPrimary : Color.appBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 44)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(role == .destructive ? AppDepth.destructiveControlGradient : AppDepth.primaryControlGradient)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.appTextPrimary.opacity(0.14), lineWidth: 1)
                        }
                }
                .appDepthShadow(elevated: role != .destructive)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
