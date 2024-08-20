/*
 * @file	CNValueTable.swift
 * @brief	Define CNValueTable class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public class CNValueTable: CNTable
{
	public static let InterfaceName = "TableIF"

	public typealias SelectedEvent = (_ rec: CNRecord) -> Void

	private var mRecordType:	CNInterfaceType
	private var mRecords:		Array<CNRecord>
	private var mSelectedEvent:	SelectedEvent?
	private var mCurrentRecord:	CNRecord?

	static func allocateInterfaceType() -> CNInterfaceType {
		let members = baseInterfaceMembers()
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public static func baseInterfaceMembers() -> Array<CNInterfaceType.Member> {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "recordCount",	type: .numberType),
			M(name: "fieldName",	type: .functionType(.stringType, [.numberType])),
			M(name: "fieldNames",	type: .functionType(.arrayType(.stringType), [])),
			M(name: "remove",	type: .functionType(.boolType, [.numberType]))
		]
		return members
	}

	private static func subInterfaceMembers(recordIF recif: CNInterfaceType) -> Array<CNInterfaceType.Member> {
		typealias M = CNInterfaceType.Member

                let recsif: CNValueType = .arrayType(.interfaceType(recif))

		let members: Array<M> = [
			M(name: "newRecord",	type: .functionType(.interfaceType(recif), [])),
			M(name: "record",	type: .functionType(.nullable(.interfaceType(recif)), [.numberType])),
			M(name: "records",	type: .functionType(recsif, [])),
			M(name: "current",	type: .nullable(.interfaceType(recif))),
			M(name: "append",	type: .functionType(.voidType, [.interfaceType(recif)])),
                        M(name: "select",       type: .functionType(recsif, [.stringType, .anyType]))
		]
		return members
	}

        public struct SubInterfaceTypes {
                public var tableInterface:      CNInterfaceType
                public var recordInterface:     CNInterfaceType
                public init(tableInterface: CNInterfaceType, recordInterface: CNInterfaceType) {
                        self.tableInterface = tableInterface
                        self.recordInterface = recordInterface
                }
        }

        public static func subInterfaceType(tableName name: String, recordIf recif: CNInterfaceType) -> SubInterfaceTypes?  {
                let tblname = name + "_" + CNValueTable.InterfaceName
                let vmgr = CNValueTypeManager.shared
                /* search base talble if */
                guard let baseif = vmgr.searchInterfaceType(byTypeName: CNValueTable.InterfaceName) else {
                        CNLog(logLevel: .error, message: "Failed to search base table interface", atFunction: #function, inFile: #file)
                        return nil
                }
                let members = CNValueTable.subInterfaceMembers(recordIF: recif)
                let tblif   = CNInterfaceType(name: tblname, base: baseif, members: members)
                return SubInterfaceTypes(tableInterface: tblif, recordInterface: recif)
        }

	public init(recordType rtype: CNInterfaceType){
		mRecordType	= rtype
		mRecords	= []
		mSelectedEvent	= nil
		mCurrentRecord	= nil
	}

	public var recordCount: Int { get {
		return mRecords.count
	}}

	public var recordType: CNInterfaceType { get {
		return mRecordType
	}}

	public func fieldName(at index: Int) -> String? {
		let membs = mRecordType.members
		if 0<=index && index<membs.count {
			return membs[index].name
		} else {
			return nil
		}
	}

	public func fieldNames() -> Array<String> {
		return mRecordType.members.map{ $0.name }
	}

	public func newRecord() -> CNRecord {
		return CNValueRecord(type: mRecordType)
	}

	public func record(at row: Int) -> CNRecord? {
		if row < mRecords.count {
			return mRecords[row]
		} else {
			return nil
		}
	}

	public func records() -> Array<CNRecord> {
		return mRecords
	}

	public var selectedEvent: SelectedEvent? {
		get          { return mSelectedEvent    }
		set(newfunc) { mSelectedEvent = newfunc }
	}

	public var current: CNRecord? { get {
		return mCurrentRecord
	}}

        public func select(name nm: String, value val: CNValue) -> Array<CNRecord> {
                var result: Array<CNRecord> = []
                for rec in mRecords {
                        if let recval = rec.value(ofField: nm) {
                                switch CNCompareValue(nativeValue0: val, nativeValue1: recval) {
                                case .orderedSame:
                                        result.append(rec)
                                case .orderedDescending, .orderedAscending:
                                        break // not mached
                                }
                        }
                }
                return result
        }

	public func append(record rcd: CNRecord) {
		mRecords.append(rcd)
	}

	public func remove(at row: Int) -> Bool {
		if row < mRecords.count {
			mRecords.remove(at: row)
			return true
		} else {
			return false
		}
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		for rec in mRecords {
			cbfunc(rec)
		}
	}

	public func load(value vals: Array<CNValue>, from filename: String?) -> NSError? {
		for val in vals {
			if let dict = val.toDictionary() {
				let newrec = CNValueRecord(type: mRecordType)
				if let err = newrec.load(value: dict, from: filename) {
					return err
				} else {
					mRecords.append(newrec)
				}
			} else {
				return NSError.parseError(message: "The record value must has dictionary")
			}
		}
		return nil
	}

	public func save(to url: URL) -> Bool {
		CNLog(logLevel: .error, message: "Not supported yet", atFunction: #function, inFile: #file)
		return false
	}
}

public class CNVirtualTable: CNTable
{
	public typealias VirtualFieldFunction = (_ fld: String, _ recidx: Int) -> CNValue

	public typealias RecordFilterFunction	= (_ rec: CNRecord) -> Bool
	public typealias CompareRecordFunction	= (_ rec0: CNRecord, _ rec1: CNRecord) -> ComparisonResult

	public typealias SelectedEvent = CNValueTable.SelectedEvent

	private var mSourceTable:   		CNTable
	private var mVirtualType:  		CNInterfaceType
	private var mVirtualRecords:		Array<CNVirtualRecord>
	private var mVirtualFieldMembers:	Array<CNInterfaceType.Member>
	private var mVirtualFieldFunc:		VirtualFieldFunction
	private var mSelectedEvent:		SelectedEvent?
	private var mCurrentRecord:		CNRecord?
	private var mRecordFilterFunction:	RecordFilterFunction?
	private var mSortOrder:			CNSortOrder?
	private var mCompareFunction:		CompareRecordFunction?

	public init(sourceTable src: CNTable){
		let rectype = src.recordType

		mSourceTable		= src
		mVirtualType		= CNInterfaceType(name: "v_" + rectype.name , base: rectype.base, members: rectype.members)
		mVirtualRecords		= []
		mVirtualFieldMembers	= []
		mVirtualFieldFunc	= { (_ fld: String, _ recid: Int) -> CNValue in return .null }
		mSelectedEvent		= nil
		mCurrentRecord		= nil
		mRecordFilterFunction	= nil
		mSortOrder		= nil
		mCompareFunction	= nil
		update()
	}

	private func update() {
		/* allocate virtual records */
		mVirtualRecords = []
		let srcnum = mSourceTable.recordCount
		for i in 0..<srcnum {
			if let rec = mSourceTable.record(at: i) {
				if filterRecord(record: rec) {
					let vfunc: CNVirtualRecord.VirtualFieldFunction = {
						(_ fld: String) -> CNValue in
						self.mVirtualFieldFunc(fld, i)
					}
					let vrec = CNVirtualRecord(
						sourceRecord:		rec,
						virtualFields:		mVirtualFieldMembers,
						virtualFieldFunction:	vfunc
					)
					mVirtualRecords.append(vrec)
				}
			}
		}
	}

	public func setVirtualFields(fields flds: Array<CNInterfaceType.Member>, fieldFunc ffunc: @escaping VirtualFieldFunction) {
		mVirtualFieldMembers	= flds
		mVirtualFieldFunc	= ffunc
		update()
	}

	public func setRecordFilterFunction(function ffunc: @escaping RecordFilterFunction){
		mRecordFilterFunction = ffunc
		update()
	}

	public func setSortOrder(order ord: CNSortOrder) {
		mSortOrder = ord
		update()
	}

	public func setCompareRecordFunction(function comp: @escaping CompareRecordFunction) {
		mCompareFunction = comp
		update()
	}

	private func filterRecord(record rec: CNRecord) -> Bool {
		if let ffunc = mRecordFilterFunction {
			return ffunc(rec)
		} else {
			return true
		}
	}

	public var recordType: CNInterfaceType { get {
		return mVirtualType
	}}

	public var recordCount: Int { get {
		return mVirtualRecords.count
	}}

	public func fieldNames() -> Array<String> {
		return mVirtualType.members.map{ $0.name }
	}

	public func fieldName(at index: Int) -> String? {
		let membs = mVirtualType.members
		if 0 <= index && index < membs.count {
			return membs[index].name
		} else {
			return nil
		}
	}

	public func newRecord() -> CNRecord {
		let srcrec = CNValueRecord(type: mSourceTable.recordType)
		let reccnt = mSourceTable.recordCount
		let vfunc: CNVirtualRecord.VirtualFieldFunction = {
			(_ fld: String) -> CNValue in
			return self.mVirtualFieldFunc(fld, reccnt)
		}
		return CNVirtualRecord(sourceRecord: srcrec, virtualFields: mVirtualFieldMembers, virtualFieldFunction: vfunc)
	}

	public var selectedEvent: SelectedEvent? {
		get          { return mSelectedEvent    }
		set(newfunc) { mSelectedEvent = newfunc }
	}

	public var current: CNRecord? { get {
		return mCurrentRecord
	}}

	public func append(record rcd: CNRecord) {
		if let vrec = rcd as? CNVirtualRecord {
			let srcrec = vrec.sourceRecord
			mSourceTable.append(record: srcrec)
			if filterRecord(record: srcrec) {
				mVirtualRecords.append(vrec)
			}
		} else {
			CNLog(logLevel: .error, message: "CNVirtualRecord is required", atFunction: #function, inFile: #file)
		}
	}

	public func record(at row: Int) -> CNRecord? {
		if row < mVirtualRecords.count {
			return mVirtualRecords[row]
		} else {
			return nil
		}
	}

	public func records() -> Array<CNRecord> {
		return mVirtualRecords
	}

	public func remove(at row: Int) -> Bool {
		if row < mVirtualRecords.count {
			mVirtualRecords.remove(at: row)
			return mSourceTable.remove(at: row)
		} else {
			return false
		}
	}

        public func select(name nm: String, value val: CNValue) -> Array<CNRecord> {
		var result: Array<CNRecord> = []
		for rec in mVirtualRecords {
			if let rval = rec.value(ofField: nm) {
				switch CNCompareValue(nativeValue0: rval, nativeValue1: val){
				case .orderedSame:
					result.append(rec)
				case .orderedAscending, .orderedDescending:
					break
				}
			}
		}
		return result
	}

	public func forEach(callback cbfunc: (CNRecord) -> Void) {
		for vrec in mVirtualRecords {
			cbfunc(vrec)
		}
	}

	public func load(value vals: Array<CNValue>, from filename: String?) -> NSError? {
		return NSError.fileError(message: "Not supported")
	}


	public func save(to url: URL) -> Bool {
		CNLog(logLevel: .error, message: "Not supported yet", atFunction: #function, inFile: #file)
		return false
	}
}

