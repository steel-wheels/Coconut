/**
 * @file	CNConfigswift
 * @brief	Define CNConfig class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

open class CNConfig
{
	public enum LogLevel: Int {

		public static let TypeName = "LogLevel"

		case nolog	= 0	// No log
		case error	= 1	// Ony error log
		case warning	= 2	// + warning log
		case debug	= 3	// + debug log
		case detail	= 4	// + detail

		public static let min	: Int	= LogLevel.nolog.rawValue
		public static let max	: Int 	= LogLevel.detail.rawValue

		public var description: String {
			get {
				let result: String
				switch self {
				case .nolog:	result = "nolog"
				case .error:	result = "error"
				case .warning:	result = "warning"
				case .debug:	result = "debug"
				case .detail:	result = "detail"
				}
				return result
			}
		}

		public static func allocateEnumType() -> CNEnumType {
			let logcode = CNEnumType(typeName: TypeName)
			logcode.add(members: [
				"nolog":	.intValue(CNConfig.LogLevel.nolog.rawValue),
				"error":	.intValue(CNConfig.LogLevel.error.rawValue),
				"warning":	.intValue(CNConfig.LogLevel.warning.rawValue),
				"debug":	.intValue(CNConfig.LogLevel.debug.rawValue),
				"detail":	.intValue(CNConfig.LogLevel.detail.rawValue)
			])
			return logcode
		}

		public func isIncluded(in level: LogLevel) -> Bool {
			return self.rawValue >= level.rawValue
		}

		public static var defaultLevel: LogLevel {
			return .warning
		}

		public static func decode(string str: String) -> LogLevel? {
			let result: LogLevel?
			switch str {
			case "nolog":		result = .nolog
			case "error":		result = .error
			case "warning":		result = .warning
			case "debug":		result = .debug
			case "detail":		result = .detail
			default:		result = nil
			}
			return result
		}
	}

	public var logLevel:	LogLevel

	public init(logLevel log: LogLevel){
		logLevel = log
	}
}

