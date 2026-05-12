//
//  AmbientGridBackdrop.swift
//  175MiraluneEchofield
//

import SwiftUI

struct AmbientGridBackdrop: View {
    private let maxColumns = 9
    private let maxRows = 12
    private let step: CGFloat = 84

    var body: some View {
        TimelineView(.animation(minimumInterval: AppDepth.canvasAnimationInterval, paused: false)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let columns = min(Int(size.width / step) + 2, maxColumns)
                let rows = min(Int(size.height / step) + 2, maxRows)
                for row in 0..<rows {
                    for column in 0..<columns {
                        let x = CGFloat(column) * step + sin(t + Double(row)) * 8
                        let y = CGFloat(row) * step + cos(t * 0.8 + Double(column)) * 6
                        let rect = CGRect(x: x, y: y, width: 44, height: 44)
                        let path = Path(roundedRect: rect, cornerRadius: 10)
                        context.stroke(
                            path,
                            with: .color(Color.appAccent.opacity(0.18)),
                            lineWidth: 2
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}
