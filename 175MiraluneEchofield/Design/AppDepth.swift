//
//  AppDepth.swift
//  175MiraluneEchofield
//
//  Shared “chrome”: gradients + a single drop shadow per surface.
//  Avoid stacking shadows, full-screen blur, and per-cell shadows on large grids.
//

import SwiftUI

enum AppDepth {
    /// ~2 updates/sec — smooth enough for backgrounds, light on GPU.
    static let canvasAnimationInterval: TimeInterval = 0.48

    /// Shared nav bar fill (one linear gradient, no blur).
    static var navigationBarFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.78),
                Color.appBackground.opacity(0.42),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func dropShadow(elevated: Bool) -> (color: Color, radius: CGFloat, y: CGFloat) {
        if elevated {
            return (Color.black.opacity(0.32), 11, 6)
        }
        return (Color.black.opacity(0.2), 6, 3)
    }

    static var cardFillGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.97),
                Color.appSurface.opacity(0.58),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cardFillGradientSoft: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.9),
                Color.appSurface.opacity(0.52),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardBorderGradient(accent: Color? = nil) -> LinearGradient {
        if let accent {
            return LinearGradient(
                colors: [accent.opacity(0.52), Color.appPrimary.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color.appPrimary.opacity(0.42), Color.appPrimary.opacity(0.06)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryControlGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appPrimary.opacity(1), Color.appPrimary.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var destructiveControlGradient: LinearGradient {
        LinearGradient(
            colors: [Color.red.opacity(0.95), Color.red.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var pillGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appPrimary.opacity(1), Color.appPrimary.opacity(0.78)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var gameTileFaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.99),
                Color.appSurface.opacity(0.78),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var sheetBackdropGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appBackground, Color.appSurface.opacity(0.88)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Modal scrim behind result panels (gradient beats flat multiply for depth).
    static var resultScrimGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.52),
                Color.appPrimary.opacity(0.14),
                Color.black.opacity(0.74),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func appDepthShadow(elevated: Bool = true) -> some View {
        let s = AppDepth.dropShadow(elevated: elevated)
        return shadow(color: s.color, radius: s.radius, x: 0, y: s.y)
    }

    /// Elevated card stack: vertical fill gradient + optional top rim light + edge + one shadow.
    func appCardDepth(
        cornerRadius: CGFloat = 18,
        elevated: Bool = true,
        accentEdge: Color? = nil,
        rimLight: Bool = false
    ) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppDepth.cardFillGradient)
                    .overlay(alignment: .top) {
                        if rimLight {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appTextPrimary.opacity(0.11), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 44)
                                .allowsHitTesting(false)
                        }
                    }
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppDepth.cardBorderGradient(accent: accentEdge), lineWidth: 1)
            }
        }
        .appDepthShadow(elevated: elevated)
    }
}

struct MiraluneEchofieldLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding(.top, 30)
            }
        }
    }
}

