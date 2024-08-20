/*
 * @file	CNValueRecord.swift
 * @brief	Define CNValueRecord class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNValueRecord: CNRecord
{
	public static let InterfaceName = "RecordIF"

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "fieldCount",	type: .numberType),
			M(name: "fieldNames",	type: .arrayType(.stringType)),
			M(name: "setValue",	type: .functionType(.voidType, [.anyType, .stringType])),
			M(name: "value",	type: .functionType(.nullable(.anyType), [.stringType]))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	private var mType:	CNInterfaceType
	private var mValue:	CNInterfaceValue

	public init(type typ: CNInterfaceType) {
		mType   = typ
		mValue  = CNInterfaceValue(types: nil, values: [:])
	}

	public var type: CNInterfaceType { get {
		return mType
	}}

	public var fieldCount: Int {
		return mType.members.count
	}

	public var fieldNames: Array<String> {
		return mType.members.map{ $0.name }
	}

	public func value(ofField name: String) -> CNValue? {
		return mValue.get(name: name)
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		if let type = mType.type(for: name) {
			if let newval = CNCastValue(from: val, to: type) {
				mValue.set(name: name, value: newval)
				return true
			}
		}
		return false
	}

	public func load(value dval: Dictionary<String, CNValue>, from filename: String?) -> NSError? {
		let formatter = CNValueFormatter()
		switch formatter.load(source: .dictionaryValue(dval), type: .interfaceType(mType), from: filename) {
		case .success(let mval):
			switch mval {
			case .interfaceValue(let ifval):
				mValue = ifval
			default:
				let err = NSError.parseError(message: "Failed to convert to interface value")
				return err
			}
		case .failure(let err):
			return err
		}
		return nil
	}

}

public class CNVirtualRecord: CNRecord
{
	public typealias VirtualFieldFunction = (_ fld: String) -> CNValue

	private var mSourceRecord:		CNRecord
	private var mVirtualFieldMembers:	Array<CNInterfaceType.Member>
	private var mVirtualFieldFunc:		VirtualFieldFunction
	private var mVirtualInterface:		CNInterfaceType

	public var sourceRecord: CNRecord { get {
		return mSourceRecord
	}}

	public init(sourceRecord src: CNRecord, virtualFields vflds: Array<CNInterfaceType.Member>, virtualFieldFunction vfunc: @escaping VirtualFieldFunction) {
		mSourceRecord		= src
		mVirtualFieldMembers	= vflds
		mVirtualFieldFunc	= vfunc
		mVirtualInterface	= src.type
		self.initRecord()
	}

	private func initRecord() {
		let srctype = mSourceRecord.type

		var members: Array<CNInterfaceType.Member> = srctype.members
		for vfld in mVirtualFieldMembers {
			members.append(vfld)
		}

		let virtype = CNInterfaceType(name: "v_" + srctype.name,
					      base: nil,
					      members: members)
		mVirtualInterface = virtype
	}

	public var type: CNInterfaceType { get {
		return mVirtualInterface
	}}

	public var fieldNames: Array<String> { get {
		return mVirtualInterface.members.map{ $0.name }
	}}

	public var fieldCount: Int {
		return mVirtualInterface.members.count
	}

	public func value(ofField name: String) -> CNValue? {
		/* First, Search virtual field */
		for memb in mVirtualFieldMembers {
			if memb.name == name {
				return mVirtualFieldFunc(name)
			}
		}
		/* If the name is not matched with virtual field, see the source table */
		return mSourceRecord.value(ofField: name)
	}

	public func setValue(value val: CNValue, forField name: String) -> Bool {
		return mSourceRecord.setValue(value: val, forField: name)
	}

	public func load(value val: Dictionary<String, CNValue>, from filename: String?) -> NSError? {
		return mSourceRecord.load(value: val, from: filename)
	}
}
