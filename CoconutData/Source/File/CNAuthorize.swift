/**
 * @file	CNAuthorize.swift
 * @brief	Define CNAuthorize class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import Foundation

public enum CNAuthorizeState: Int
{
	public static let TypeName = "Authorize"

	case Undetermined	= 0
	case Examinating	= 1
	case Denied		= 2
	case Authorized		= 3

	public static func allocateEnumType() -> CNEnumType {
		let authorize = CNEnumType(typeName: TypeName)
		authorize.add(members: [
			"undetermined":		.intValue(CNAuthorizeState.Undetermined.rawValue),
			"examinating":		.intValue(CNAuthorizeState.Examinating.rawValue),
			"denied":		.intValue(CNAuthorizeState.Denied.rawValue),
			"authorized":		.intValue(CNAuthorizeState.Authorized.rawValue)
		])
		return authorize
	}

	public var description: String {
		var result: String
		switch self {
		case .Undetermined:	result = "undetermined"
		case .Examinating:	result = "examinating"
		case .Denied:		result = "denied"
		case .Authorized:	result = "authorized"
		}
		return result
	}
}

