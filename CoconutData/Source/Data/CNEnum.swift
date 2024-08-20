/**
 * @file	CNEnum.swift
 * @brief	Define CNEnum class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import Foundation

public struct CNEnum
{
	public static let 	ClassName = "enum"
	public typealias	Value     = CNEnumType.Value

	private weak var	mEnumType:	CNEnumType?
	private var 		mMemberName:	String

	public var enumType: CNEnumType? { get {
		return mEnumType
	}}

	public var memberName: String { get {
		return mMemberName
	}}

	public init(type t: CNEnumType, member n: String){
		mEnumType	= t
		mMemberName	= n
	}

	public var typeName: String { get {
		if let etype = mEnumType {
			return etype.typeName
		} else {
			CNLog(logLevel: .error, message: "No owner type", atFunction: #function, inFile: #file)
			return "?"
		}
	}}

	public var value: Value { get {
		if let etype = mEnumType {
			if let val = etype.value(forMember: mMemberName) {
				return val
			} else {
				CNLog(logLevel: .error, message: "No value for member \(mMemberName)", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "No owner type", atFunction: #function, inFile: #file)
		}
		return .intValue(0)
	}}

	public static func fromValue(typeName tname: String, memberName mname: String) -> CNEnum? {
		let vmgr = CNValueTypeManager.shared
		if let etype = vmgr.searchEnumType(byTypeName: tname) {
			if let _ = etype.value(forMember: mname) {
				return CNEnum(type: etype, member: mname)
			} else {
				CNLog(logLevel: .error, message: "Enum member is not found. type:\(tname), member:\(mname)", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Enum type is not found: \(tname)", atFunction: #function, inFile: #file)
		}
		return nil
	}

	public static func fromValue(value val: CNValue) -> CNEnum? {
		if let dict = val.toDictionary() {
			return fromValue(value: dict)
		} else {
			return nil
		}
	}

	public static func fromValue(value val: Dictionary<String, CNValue>) -> CNEnum? {
		if let typeval = val["type"], let membval = val["member"] {
			if let typestr = typeval.toString(), let membstr = membval.toString() {
				return fromValue(typeName: typestr, memberName: membstr)
			}
		}
		CNLog(logLevel: .error, message: "No such enum value", atFunction: #function, inFile: #file)
		return nil
	}

	public func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNEnum.ClassName),
			"type":		.stringValue(self.typeName),
			"member":	.stringValue(self.memberName)
		]
		return result
	}
}

public class CNEnumType
{
	public  static let typeName		= "enum"
	private static let NameItem		= "name"
	private static let MembersItem		= "members"

	public enum Value {
		case intValue(Int)
		case stringValue(String)

		public func toValue() -> CNValue {
			switch self {
			case .intValue(let ival):	return CNValue.numberValue(NSNumber(integerLiteral: ival))
			case .stringValue(let sval):	return CNValue.stringValue(sval)
			}
		}

		public func toScript() -> String {
			switch self {
			case .intValue(let ival):	return "\(ival)"
			case .stringValue(let sval):	return "\"\(sval)\""
			}
		}

		public static func compare(_ val0: Value, _ val1: Value) -> ComparisonResult {
			/* int < string */
			let result: ComparisonResult
			switch val0 {
			case intValue(let e0):
				switch val1 {
				case intValue(let e1):
					result = CNCompare(e0, e1)
				case stringValue(_):
					result = .orderedAscending
				}
			case stringValue(let e0):
				switch val1 {
				case intValue(_):
					result = .orderedDescending
				case stringValue(let e1):
					result = CNCompare(e0, e1)
				}
			}
			return result
		}
	}

	private var mTypeName:		String
	private var mMembers:		Dictionary<String, Value>	// <member-name, value>

	public var typeName: String { get { return mTypeName }}
	public var members: Dictionary<String, Value> { get { return mMembers }}

	public init(typeName name: String){
		mTypeName  = name
		mMembers   = [:]
	}

	public func allocate(name nm: String) -> CNEnum? {
		if let _ = mMembers[nm] {
			return CNEnum(type: self, member: nm)
		} else {
			return nil
		}
	}

	public func add(name nm: String, value val: Value){
		mMembers[nm] = val
	}

	public func add(members membs: Dictionary<String, Value>){
		for key in membs.keys.sorted() {
			if let val = membs[key] {
				self.add(name: key, value: val)
			}
		}
	}

	public var names: Array<String> { get {
		return mMembers.keys.sorted()
	}}

	public func value(forMember name: String) -> Value? {
		return mMembers[name]
	}

	public func search(byValue targ: Value) -> CNEnum? {
		for (key, val) in mMembers {
			switch CNEnum.Value.compare(targ, val) {
			case .orderedSame:
				return CNEnum(type: self, member: key)
			case .orderedAscending, .orderedDescending:
				break
			}
		}
		return nil
	}

	public static func compare(_ s0: CNEnumType, _ s1: CNEnumType) -> ComparisonResult {
		return CNCompare(s0.typeName, s1.typeName)
	}

	public func toValue(isInside inside: Bool) -> Dictionary<String, CNValue> {
		var result: Dictionary<String, CNValue> = [:]
		result[CNEnumType.NameItem] = .stringValue(mTypeName)
		if !inside {
			var members: Dictionary<String, CNValue> = [:]
			for (name, val) in mMembers {
				switch val {
				case .intValue(let imm):
					members[name] = .numberValue(NSNumber(integerLiteral: imm))
				case .stringValue(let imm):
					members[name] = .stringValue(imm)
				}
			}
			result[CNEnumType.MembersItem] = .dictionaryValue(members)
		}
		return result
	}

	public static func fromValue(value val: Dictionary<String, CNValue>, isInside inside: Bool) -> Result<CNValueType, NSError> {
		guard let ename = CNValue.stringProperty(name: CNEnumType.NameItem, in: val) else {
			return .failure(NSError.parseError(message: "No \(CNEnumType.NameItem) property for enum"))
		}
		let vmgr = CNValueTypeManager.shared
		let result: CNValueType
		if inside {
			if let etype = vmgr.searchEnumType(byTypeName: ename) {
				result = .enumType(etype)
			} else {
				return .failure(NSError.parseError(message: "Unknown enum type: \(ename)"))
			}
		} else {
			guard let membs = CNValue.dictionaryProperty(name: CNEnumType.MembersItem, in: val) else {
				return .failure(NSError.parseError(message: "No \(CNEnumType.MembersItem) property for enum"))
			}
			let etype = CNEnumType(typeName: ename)
			for (name, val) in membs {
				switch val {
				case .numberValue(let num):
					etype.add(name: name, value: .intValue(num.intValue))
				case .stringValue(let str):
					etype.add(name: name, value: .stringValue(str))
				default:
					CNLog(logLevel: .error, message: "Unexpected enum member: \(ename)", atFunction: #function, inFile: #file)
				}
			}
			vmgr.add(enumType: etype)
			result = .enumType(etype)
		}
		return .success(result)
	}
}
