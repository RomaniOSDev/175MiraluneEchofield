//
//  LevelBestRecord.swift
//  175MiraluneEchofield
//

import Foundation

struct LevelBestRecord: Codable, Equatable {
    var bestTimeSeconds: Int?
    /// Moves, swipes, or rhythm move count depending on activity.
    var bestPrimaryMetric: Int?

    mutating func consider(time: Int, metric: Int) {
        if let old = bestTimeSeconds {
            if time < old {
                bestTimeSeconds = time
            }
        } else {
            bestTimeSeconds = time
        }
        if let old = bestPrimaryMetric {
            if metric < old {
                bestPrimaryMetric = metric
            }
        } else {
            bestPrimaryMetric = metric
        }
    }
}
