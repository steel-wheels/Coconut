/**
 * @file	CNAlert.swift
 * @brief	Define CNAlert class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

/* Common implementation of NSAlert.Style */
public enum CNAlertType: Int {
	public static let	TypeName	= "AlertType"

	case	informational	= 1
	case 	warning		= 2
	case	critical	= 3

	public static func allocateEnumType() -> CNEnumType {
		let alertcode = CNEnumType(typeName: TypeName)
		alertcode.add(members: [
			"informational":	.intValue(CNAlertType.informational.rawValue),
			"warning":		.intValue(CNAlertType.warning.rawValue),
			"critical": 		.intValue(CNAlertType.critical.rawValue)
		])
		return alertcode
	}
}

