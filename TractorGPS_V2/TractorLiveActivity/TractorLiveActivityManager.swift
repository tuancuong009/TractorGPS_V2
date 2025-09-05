//
//  TractorLiveActivityManager.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 5/9/25.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct TractorActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var heading: Double
        var coveredArea: Double
        var speed: Double
        var isTracking: Bool
        var distanceFromLine: Double // Add this
        var shouldTurnLeft: Bool // Add this
    }
}

// LiveActivityManager.swift
class TractorLiveActivityManager {
    static let shared = TractorLiveActivityManager()
    private var currentActivity: Activity<TractorActivityAttributes>?

    func startActivity(heading: Double, speed: Double, area: Double) {
        // End previous activity if exists
        endCurrentActivity()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TractorActivityAttributes()
        let contentState = TractorActivityAttributes.ContentState(
            heading: heading,
            coveredArea: area,
            speed: speed,
            isTracking: true,
            distanceFromLine: 0,
            shouldTurnLeft: false
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Error starting activity: \(error)")
        }
    }

    func updateActivity(heading: Double, speed: Double, area: Double, isTracking: Bool, distanceFromLine: Double, shouldTurnLeft: Bool) {
        guard let activity = currentActivity else { return }

        Task {
            let state = TractorActivityAttributes.ContentState(
                heading: heading,
                coveredArea: area,
                speed: speed,
                isTracking: isTracking,
                distanceFromLine: distanceFromLine,
                shouldTurnLeft: shouldTurnLeft
            )
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    func endCurrentActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(
                ActivityContent(
                    state: activity.content.state,
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
            currentActivity = nil
        }
    }
}
