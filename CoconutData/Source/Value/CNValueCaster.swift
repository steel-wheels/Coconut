/*
 * @file	CNValueCaster.swift
 * @brief	Define CNValueCaster class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation

public func CNCastValue(from srcval: CNValue, to dsttyp: CNValueType) -> CNValue?
{
	let srctype = srcval.valueType
	switch CNValueType.compare(type0: srctype, type1: dsttyp){
	case .orderedSame:
		return srcval 	// Needless to cast
	case .orderedAscending, .orderedDescending:
		break
	}

	var result: CNValue? = nil
	switch dsttyp {
	case .voidType:
		CNLog(logLevel: .error, message: "Unexpected target type", atFunction: #function, inFile: #file)
	case .anyType:
		result = srcval	// any type will be accepted
	case .boolType:
		if let flag = srcval.toBool() {
			result = .boolValue(flag)
		}
	case .numberType:
		if let num = srcval.toNumber() {
			result = .numberValue(num)
		}
	case .stringType:
		if let str = srcval.toString() {
			result = .stringValue(str)
		}
	case .enumType(let etype):
		if let num = srcval.toNumber() {
			if let eval = etype.search(byValue: .intValue(num.intValue)) {
				result = .enumValue(eval)
			} else {
				CNLog(logLevel: .error, message: "Failed to cast int to enum for \(etype.typeName)", atFunction: #function, inFile: #file)
			}
		}
	case .dictionaryType(_), .arrayType(_), .setType(_), .objectType(_), .interfaceType(_), .functionType(_, _), .nullable(_):
		break	// These type does not match with other types
	}
	return result
}


