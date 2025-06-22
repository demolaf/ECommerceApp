//
//  Date+String.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import Foundation

extension Date {
    nonisolated func toISO8601String(includeFractionalSeconds: Bool = false) -> String {
        let formatter = ISO8601DateFormatter()
        if includeFractionalSeconds {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        }
        return formatter.string(from: self)
    }
}

extension String {
    /// Converts an ISO 8601 date string to a Date object
    nonisolated func iso8601ToDate() -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self) ?? .init()
    }
}
