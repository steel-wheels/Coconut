/**
 * @file	CNProperties.swift
 * @brief	Define CNProperties protocol
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNValueProperties: CNProperties
{
	public static let ClassName     = "Properties"
	public static let InterfaceName = "PropertiesIF"

	private var mType: 	CNInterfaceType
	private var mValue:	CNInterfaceValue

	public init(type typ: CNInterfaceType){
		mType  = typ
		mValue = CNInterfaceValue(types: typ, values: [:])
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members = baseInterfaceMembers()
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public static func baseInterfaceMembers() -> Array<CNInterfaceType.Member> {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "count",	type: .numberType),
			M(name: "names",	type: .arrayType(.stringType)),
			M(name: "value",	type: .functionType(.anyType, [.stringType])),
			M(name: "set",		type: .functionType(.boolType, [.anyType, .stringType]))
		]
		return members
	}

	private static func subInterfaceMembers(recordIF recif: CNInterfaceType) -> Array<CNInterfaceType.Member> {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "properties",	type: .interfaceType(recif)),
		]
		return members
	}

	public var type:  CNInterfaceType { get { return mType }}
	public var count: Int { get { return mValue.values.count }}

	public var properties: Dictionary<String, CNValue> { get {
		return mValue.values
	}}

	public var names: Array<String> { get { return mType.members.map{ $0.name } }}

	public func name(at index: Int) -> String? {
		if 0<=index && index<mType.members.count {
			return mType.members[index].name
		} else {
			return nil
		}
	}

	public var values: Array<CNValue> { get { return Array(mValue.values.values) }}

	public func value(byName name: String) -> CNValue? {
		return mValue.get(name: name)
	}

	public func set(value val: CNValue, forName name: String) {
        mValue.set(name: name, value: val)
	}

	public func load(value val: Dictionary<String, CNValue>, from filename: String?) -> NSError? {
		let formatter = CNValueFormatter()
		switch formatter.load(source: .dictionaryValue(val), type: .interfaceType(mType), from: filename) {
		case .success(let retval):
			switch retval {
			case .interfaceValue(let ifval):
				mValue = ifval
			default:
				let err = NSError.parseError(message: "Interface value is required")
				return err
			}
		case .failure(let err):
			return err
		}
		return nil
	}

	public func save(to url: URL) -> Bool {
		CNLog(logLevel: .error, message: "Not supported yet", atFunction: #function, inFile: #file)
		return false
	}

    public func toText() -> CNText {
        let val: CNValue = .interfaceValue(mValue)
        return val.toScript()
    }
}

