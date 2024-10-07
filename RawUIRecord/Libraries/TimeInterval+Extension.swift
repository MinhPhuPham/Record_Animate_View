//
//  ExtensionsLiquid.swift
//  RawUIRecord
//
//  Created by Phu Pham on 7/10/24.
//

import Foundation

extension TimeInterval {
    /// The number of nanoseconds in one second.
    static let nanosecondsPerSecond = TimeInterval(NSEC_PER_SEC)
}

extension Task where Failure == Error {
    /// Create a delayed task that will wait for the given duration before performing its operation.
    @discardableResult static func delayed(by delay: OperationQueue.SchedulerTimeType.Stride, priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) -> Task {
        Task(priority: priority) {
            try await Task<Never, Never>.sleep(nanoseconds: UInt64(delay.timeInterval * .nanosecondsPerSecond))
            return try await operation()
        }
    }
}
