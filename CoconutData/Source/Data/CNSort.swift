/**
 * @file	CNSort.swift
 * @brief	Type definition of sorting
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public enum CNSortOrder: Int
{
	static let TypeName = "SortOrder"

	case none		=  0	// No sort
	case increasing		= -1	// smaller first
	case decreasing		=  1	// bigger first

	static func allocateEnumType() -> CNEnumType {
		let sortorder = CNEnumType(typeName: CNSortOrder.TypeName)
		sortorder.add(members: [
			"none":			.intValue(CNSortOrder.none.rawValue),
			"increasing":		.intValue(CNSortOrder.increasing.rawValue),
			"decreasing":		.intValue(CNSortOrder.decreasing.rawValue)
		])
		return sortorder
	}

	public var description: String { get {
		let result: String
		switch self {
		case .none:		result = "none"
		case .increasing:	result = "increasing"
		case .decreasing:	result = "decreasing"
		}
		return result
	}}
}

