/*
 * @file	CNValueInterface.swift
 * @brief	Define CNValueInterface class
 * @par Copyright
 *   Copyright (C) 2022-2023 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNInterfaceType
{
	public static  let typeName		= "interface"
	private static let BaseItem		= "base"
	private static let NameItem		= "name"
	private static let MemberNameItem	= "name"
	private static let MemberTypeItem	= "type"
	private static let MembersItem		= "members"

	static private var mUniqId = 0

	public struct Member {
		public var name:	String
		public var type:	CNValueType
		public init(name nm: String, type typ: CNValueType){
			name = nm
			type = typ
		}
	}

	private var	mName:		String
	private var	mBase:		CNInterfaceType?
	private var	mMembers:	Array<Member>

	public var name:	String			{ get { return mName	}}
	public var base:	CNInterfaceType?	{ get { return mBase	}}
	public var members:	Array<Member>		{ get { return mMembers	}}

	public static var mNilType: CNInterfaceType = CNInterfaceType(name: "Nil", base: nil, members: [])
	public static var nilType: CNInterfaceType { get {
		return mNilType
	}}

	public init(name nm: String, base bs: CNInterfaceType?, members src: Array<Member>) {
		mName		= nm
		mBase		= bs
		mMembers	= src
	}

	public func add(members membs: Array<Member>){
		mMembers.append(contentsOf: membs)
	}

	public var allTypes: Array<Member> { get {
		var result: Array<Member> = []
		if let base = mBase {
			result.append(contentsOf: base.members)
		}
		for memb in self.members {
			if let _ = search(byName: memb.name, in: result) {
				result.append(memb)
			}
		}
		return result
	}}

	public func member(for name: String) -> Member? {
		if let memb = search(byName: name, in: mMembers) {
			return memb
		} else {
			return nil
		}
	}

	public func type(for name: String) -> CNValueType? {
		if let memb = search(byName: name, in: mMembers) {
			return memb.type
		} else {
			return nil
		}
	}

	public static func compare(_ s0: CNInterfaceType, _ s1: CNInterfaceType) -> ComparisonResult {
		return CNCompare(s0.name, s1.name)
	}

	public static func temporaryName() -> String {
		let name = "_iftyp\(mUniqId)"
		mUniqId += 1
		return name
	}

	private func search(byName name: String, in members: Array<Member>) -> Member? {
		for memb in members {
			if memb.name == name {
				return memb
			}
		}
		return nil
	}
}

public class CNInterfaceValue
{
	private var mType:	CNInterfaceType?
	private var mTypeCache:	CNInterfaceType?
	private var mValues:	Dictionary<String, CNValue>

	public var values: Dictionary<String, CNValue> { get { return mValues }}

	public init(types tsrc: CNInterfaceType?, values vsrc: Dictionary<String, CNValue>) {
		mType		= tsrc
		mTypeCache	= nil
		mValues		= vsrc

		/* allocate types */
		if mType == nil {
			mTypeCache = allocateType(values: mValues)
		}
	}

	public func get(name nm: String) -> CNValue? {
		return mValues[nm]
	}

	public func set(name nm: String, value val: CNValue) {
		if let _ = self.type.member(for: nm) {
			mValues[nm] = val
		} else {
			CNLog(logLevel: .error, message: "Unexpected property: \(nm)",
			      atFunction: #function, inFile: #file)
		}
	}

	public var type: CNInterfaceType { get {
		if let typ = mType {
			return typ
		} else if let typ = mTypeCache {
			return typ
		} else {
			fatalError("Can not happen")
		}
	}}

	public static func fromValue(className clsname: String, value dict: Dictionary<String,CNValue>) -> CNInterfaceValue? {
		var result: CNInterfaceValue? = nil
		let vmgr = CNValueTypeManager.shared
		if let iftype = vmgr.searchInterfaceType(byTypeName: clsname) {
			var ptypes = dict ; ptypes["class"] = nil
			result  = CNInterfaceValue(types: iftype, values: ptypes)
		}
		return result
	}

	private func allocateType(values vals: Dictionary<String, CNValue>) -> CNInterfaceType {
		let name = CNInterfaceType.temporaryName()

		var members: Array<CNInterfaceType.Member> = []
		for (key, val) in mValues {
			let newmemb = CNInterfaceType.Member(name: key, type: val.valueType)
			members.append(newmemb)
		}
		let newif = CNInterfaceType(name: name, base: nil, members: members)
		/* Add to table */
		let vmgr = CNValueTypeManager.shared
		vmgr.add(interfaceType: newif)
		return newif
	}
}

