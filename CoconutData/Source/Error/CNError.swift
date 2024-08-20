/**
 * @file	CNErrorExtension.swift
 * @brief	Extend NSError class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

import Foundation

public enum CNErrorCode: Int {
	case noError		= 0
	case information	= 1
	case internalError	= 2
	case parseError		= 3
	case parameterError	= 4
	case execError		= 5
	case fileError		= 6
	case dataError		= 7
	case unknownError	= 8
}

public extension NSError
{
	class func domain() -> String {
		return "gitlab.com.steelwheels.Coconut"
	}

	class func errorLocationKey() -> String {
		return "errorLocation"
	}

	class func informationNotice(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		return NSError(domain: self.domain(), code: CNErrorCode.information.rawValue, userInfo: userinfo)
	}

	class func internalError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		return NSError(domain: self.domain(), code: CNErrorCode.internalError.rawValue, userInfo: userinfo)
	}

	class func internalError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		return NSError(domain: self.domain(), code: CNErrorCode.internalError.rawValue, userInfo: userinfo)
	}

	class func parseError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		return NSError(domain: self.domain(), code: CNErrorCode.parseError.rawValue, userInfo: userinfo)
	}

	class func parseError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		return NSError(domain: self.domain(), code: CNErrorCode.parseError.rawValue, userInfo: userinfo)
	}

	class func fileError(message m: String) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: m]
		let error = NSError(domain: self.domain(), code: CNErrorCode.fileError.rawValue, userInfo: userinfo)
		return error
	}

	class func fileError(message m: String, location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: m), self.errorLocationKey(): l]
		return NSError(domain: self.domain(), code: CNErrorCode.fileError.rawValue, userInfo: userinfo)
	}

	class func unknownError() -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: "Unknown error"]
		return NSError(domain: self.domain(), code: CNErrorCode.unknownError.rawValue, userInfo: userinfo)
	}

	class func unknownError(location l: NSString) -> NSError {
		let userinfo = [NSLocalizedDescriptionKey: NSString(string: "Unknown error"), self.errorLocationKey(): l]
		return NSError(domain: self.domain(), code: CNErrorCode.unknownError.rawValue, userInfo: userinfo)
	}

	var errorCode: CNErrorCode { get {
			if let ecode = CNErrorCode(rawValue: code) {
				return ecode
			} else {
				return .unknownError
			}
	}}

	func toString() -> String {
		let dict : Dictionary = userInfo
		var message = self.localizedDescription
		let lockey : String = NSError.errorLocationKey()
		if let location = dict[lockey] as? String {
			message = message + "in " + location
		}
		return message
	}
}


