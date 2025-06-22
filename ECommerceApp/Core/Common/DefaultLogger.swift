//
//  DefaultLogger.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import Foundation
import os

nonisolated public class DefaultLogger {
    private init() {}
    private static let subsystem: String = Bundle.main.bundleIdentifier ?? "DefaultLogger"

    @available(iOS 14.0, macOS 11.0, *)
    private static func logger(for tag: String) -> Logger {
        Logger(subsystem: subsystem, category: tag)
    }

    static public func log(_ object: AnyObject, functionName: String? = nil, _ message: String) {
        let tag = String(describing: type(of: object))

        if #available(iOS 14.0, macOS 11.0, *) {
            let logger = logger(for: tag)
            if let functionName {
                logger.info("[\(tag)], \(functionName) - \(message)")
            } else {
                logger.info("[\(tag)] - \(message)")
            }
        } else {
            if let functionName {
                debugPrint("[\(tag)], \(functionName) - \(message)")
            } else {
                debugPrint("[\(tag)] - \(message)")
            }
        }
    }
}
