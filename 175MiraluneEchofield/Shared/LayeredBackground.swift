//
//  LayeredBackground.swift
//  175MiraluneEchofield
//

import SwiftUI

struct LayeredBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appSurface.opacity(0.9),
                    Color.appPrimary.opacity(0.06),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            CanvasPatternView()
                .opacity(0.35)
        }
        .ignoresSafeArea()
    }
}

private struct CanvasPatternView: View {
    private let maxColumns = 10
    private let maxRows = 14

    var body: some View {
        TimelineView(.animation(minimumInterval: AppDepth.canvasAnimationInterval, paused: false)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let spacing: CGFloat = 42
                let columns = min(Int(size.width / spacing) + 2, maxColumns)
                let rows = min(Int(size.height / spacing) + 2, maxRows)
                var path = Path()
                for col in 0..<columns {
                    for row in 0..<rows {
                        let x = CGFloat(col) * spacing
                        let y = CGFloat(row) * spacing
                        let offset = sin(t * 0.6 + x * 0.01) * 6
                        let rect = CGRect(x: x + offset, y: y, width: 10, height: 10)
                        path.addEllipse(in: rect)
                    }
                }
                context.fill(path, with: .color(Color.appPrimary.opacity(0.12)))
            }
        }
    }
}
