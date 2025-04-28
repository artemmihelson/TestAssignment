//
//  MockClock.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 28.04.2025.
//

import ComposableArchitecture
import Foundation

actor MockClock: @preconcurrency Clock {
    var now = ContinuousClock().now
    var minimumResolution = ContinuousClock().minimumResolution
    
    typealias Instant = ContinuousClock.Instant
    
    func sleep(until deadline: Instant, tolerance: Duration?) async throws {
        // No-op implementation for testing
    }
    
    // Method to manually advance the clock
    func advance(by duration: Duration) {
        now = now.advanced(by: duration)
    }
    
    // Method to create a controlled timer for testing
    func timer(interval: Duration) -> AsyncStream<Instant> {
        return AsyncStream { continuation in
            continuation.yield(now)
            continuation.finish()
        }
    }
}
