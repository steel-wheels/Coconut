/**
 * @file	CNAddressBook.swift
 * @brief	Define CNAddressBook class
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 * @reference
 * - https://qiita.com/kato-i-l/items/0d79e8dcbc15541a5b0f
 */

import CoconutData
import Contacts
import Foundation

public class CNContactDatabase: CNTable
{
	public typealias SelectedEvent = CNValueTable.SelectedEvent

	private enum State: Int32 {
		case undecided			= 0
		case accessAuthorized		= 1
		case accessDenied		= 2
		case loadFailed			= 3
		case loaded			= 4
	}

	private var mRecordType: 	CNInterfaceType
	private var mRecords:		Array<CNRecord>
	private var mSelectedEvent:	SelectedEvent?
	private var mCurrentRecord:	CNRecord?
	private var mState:		State

	public var recordType: CNInterfaceType { get {
		return mRecordType
	}}

	public var recordCount: Int { get {
		return mRecords.count
	}}

	public init() {
		mRecordType  	= CNContactDatabase.allocateRecordType()
		mRecords 	= []
		mSelectedEvent	= nil
		mCurrentRecord	= nil
		mState   	= .undecided
	}

	private static func allocateRecordType() -> CNInterfaceType {
		var members: Array<CNInterfaceType.Member> = []
		let fields = CNContactField.allFields
		for field in fields {
			let newmemb = CNInterfaceType.Member(name: field.toKey(), type: .stringType)
			members.append(newmemb)
		}
		return CNInterfaceType(name: "ContactIF", base: nil, members: members)
	}

	public func fieldName(at index: Int) -> String? {
		let membs = mRecordType.members
		if 0<=index && index<membs.count {
			return membs[index].name
		}
		return nil
	}

	public func fieldNames() -> Array<String> {
		return mRecordType.members.map{ $0.name }
	}

	public func newRecord() -> CNRecord {
		return CNValueRecord(type: mRecordType)
	}

	public func record(at row: Int) -> CNRecord? {
		if 0 <= row && row < mRecords.count {
			return mRecords[row]
		} else {
			return nil
		}
	}

	public func records() -> Array<CNRecord> {
		return mRecords
	}

	public var selectedEvent: SelectedEvent? {
		get          { return mSelectedEvent }
		set(newfunc) { mSelectedEvent = newfunc }
	}

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

	public var current: CNRecord? { get {
		return mCurrentRecord
	}}

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

	public func search(value val: CNValue, forField field: String) -> Array<CNRecord> {
		var result: Array<CNRecord> = []
		for rec in mRecords {
			if let fval = rec.value(ofField: field) {
				switch CNCompareValue(nativeValue0: val, nativeValue1: fval){
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
		for rec in mRecords {
			cbfunc(rec)
		}
	}

	public func load(value val: Array<CNValue>, from filename: String?) -> NSError? {
		return NSError.fileError(message: "Not supported")
	}

	public func save(to url: URL) -> Bool {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
		return false
	}

	public static func fromValue(_ src: Dictionary<String, CNValue>) -> Result<CNTable, NSError> {
		/* The note format section is ignored */

		guard let recsval = src["records"] else {
			let err = NSError.parseError(message: "Table value must have \"records\" property")
			return .failure(err)
		}
		guard let recsarr = recsval.toArray() else {
			let err = NSError.parseError(message: "The \"records\" property must have item array")
			return .failure(err)
		}

		let newtable = CNContactDatabase()
		for recsval in recsarr {
			if let recval = recsval.toDictionary() {
				let newrec = newtable.newRecord()
				for (rkey, rval) in recval {
					if !newrec.setValue(value: rval, forField: rkey){
						let err = NSError.parseError(message: "Failed to set record value for key: \(rkey)")
						return .failure(err)
					}
				}
				newtable.append(record: newrec)
			} else {
				let err = NSError.parseError(message: "The \"record\" property must have dictionary")
				return .failure(err)
			}
		}
		return .success(newtable)
	}

	public func authorize(callback cbfunc: @escaping (_ state: Bool) -> Void) {
		switch mState {
		case .accessAuthorized, .loaded:
			cbfunc(true)
			return
		case .undecided:
			break // continue
		case .accessDenied, .loadFailed:
			cbfunc(false)
			return
		}

		switch CNContactStore.authorizationStatus(for: .contacts) {
		case .authorized:
			mState = .accessAuthorized
			cbfunc(true)
                case .denied, .limited:
			mState = .accessDenied
			cbfunc(false)
		case .notDetermined, .restricted:
			let store     = CNContactStore()
			store.requestAccess(for: .contacts, completionHandler: {
				(_ granted: Bool, _ error: Error?) -> Void in
				if granted {
					self.mState = .accessAuthorized
					cbfunc(true)
				} else {
					self.mState = .accessDenied
					cbfunc(false)
				}
			})
                @unknown default:
			CNLog(logLevel: .error, message: "Unknown case", atFunction: #function, inFile: #file)
			mState = .accessDenied
			cbfunc(false)
		}
	}
}
