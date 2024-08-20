/*
 * @file	CNValueType.swift
 * @brief	Define CNValueType class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

/**
 * The data to present JSValue as native data
 */
public indirect enum CNValueType
{
	public static let typeName		= "ValueType"
	private static let TypeItem		= "type"
	private static let ElementTypeItem	= "elementType"
	private static let ObjectTypeItem	= "objectType"
	private static let ParameterTypesItem	= "parameterTypes"
	private static let ReturnTypeItem	= "returnType"

	case	voidType
	case	anyType
	case	boolType
	case	numberType
	case	stringType
	case	enumType(CNEnumType)				// enum-type
	case	dictionaryType(CNValueType)			// element type
	case	arrayType(CNValueType)				// element type
	case	setType(CNValueType)				// element type
	case	objectType(String?)				// class name or unkown
	case 	interfaceType(CNInterfaceType)			// interface name
	case	functionType(CNValueType, Array<CNValueType>)	// (return-type, parameter-types)
	case	nullable(CNValueType)				// (type | null)

	public var typeName: String { get {
		let result: String
		switch self {
		case .voidType:			result = "void"
		case .anyType:			result = "any"
		case .boolType:			result = "boolean"
		case .numberType:		result = "number"
		case .stringType:		result = "string"
		case .enumType(_):		result = CNEnumType.typeName
		case .dictionaryType(_):	result = "dictionary"
		case .arrayType(_):		result = "array"
		case .setType(_):		result = "set"
		case .objectType(_):		result = "object"
		case .interfaceType(_):		result = CNInterfaceType.typeName
		case .functionType(_, _):	result = "function"
		case .nullable(_):		result = "nullable"
		}
		return result
	}}

	public static func encode(valueType vtype: CNValueType) -> String {
		return CNValueTypeCoder.encode(valueType: vtype)
	}

	public static func decode(code str: String) -> Result<CNValueType, NSError> {
		return CNValueTypeCoder.decode(code: str)
	}

	public static func compare(type0 t0: CNValueType, type1 t1: CNValueType) -> ComparisonResult {
		let imm0 = t0.typeName
		let imm1 = t1.typeName
		switch CNCompare(imm0, imm1) {
		case .orderedSame:
			var result: ComparisonResult = .orderedSame
			switch t0 {
			case .enumType(let e0):
				switch t1 {
				case .enumType(let e1):
					result = CNEnumType.compare(e0, e1)
				default:
					NSLog("can not happen (enum)")
				}
			case .dictionaryType(let e0):
				switch t1 {
				case .dictionaryType(let e1):
					result = compare(type0: e0, type1: e1)
				default:
					NSLog("can not happen (dictionary)")
				}
			case .arrayType(let e0):
				switch t1 {
				case .arrayType(let e1):
					result = compare(type0: e0, type1: e1)
				default:
					NSLog("can not happen (array)")
				}
			case .setType(let e0):
				switch t1 {
				case .setType(let e1):
					result = compare(type0: e0, type1: e1)
				default:
					NSLog("can not happen (set)")
				}
			case .objectType(let e0):
				switch t1 {
				case .objectType(let e1):
					let s0 = e0 ?? "" ; let s1 = e1 ?? ""
					result = CNCompare(s0, s1)
				default:
					NSLog("can not happen (set)")
				}
			case .interfaceType(let e0):
				switch t1 {
				case .interfaceType(let e1):
					result = CNInterfaceType.compare(e0, e1)
				default:
					NSLog("can not happen (interfaceType)")
				}
			case .functionType(let rtype0, let ptypes0):
				switch t1 {
				case .functionType(let rtype1, let ptypes1):
					switch compare(type0: rtype0, type1: rtype1) {
					case .orderedSame:
						result = compare(types0: ptypes0, types1: ptypes1)
					case .orderedAscending:
						result = .orderedAscending
					case .orderedDescending:
						result = .orderedDescending
					}
				default:
					NSLog("can not happen (functionType)")
				}
			case .nullable(let e0):
				switch t1 {
				case .nullable(let e1):
					result = compare(type0: e0, type1: e1)
				default:
					NSLog("can not happen (nullableType)")
				}
			default:
				result = .orderedSame
			}
			return result
		case .orderedAscending:
			return .orderedAscending
		case .orderedDescending:
			return .orderedDescending
		}
	}

	private static func compare(types0 ts0 :Array<CNValueType>, types1 ts1: Array<CNValueType>) -> ComparisonResult {
		let result: ComparisonResult
		switch CNCompare(ts0.count, ts1.count) {
		case .orderedSame:
			var tmpres: ComparisonResult = .orderedSame
			loop: for i in 0..<ts0.count {
				switch compare(type0: ts0[i], type1: ts1[i]) {
				case .orderedSame:
					break
				case .orderedAscending:
					tmpres = .orderedAscending
					break loop
				case .orderedDescending:
					tmpres = .orderedDescending
					break loop
				}
			}
			result = tmpres
		case .orderedAscending:
			result = .orderedAscending
		case .orderedDescending:
			result = .orderedDescending
		}
		return result
	}
}
