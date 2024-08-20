/**
 * @file	CNTable.swift
 * @brief	Define CNTable protocol
 * @par Copyright
 *   Copyright (C) 2021-2022 Steel Wheels Project
 */

import Foundation

public enum CNTableLoadResult {
	case ok
	case error(NSError)
}

public protocol CNTable
{
	var recordType: CNInterfaceType { get }

	var recordCount: Int { get }
	func fieldName(at index: Int) -> String?
	func fieldNames() -> Array<String>

	func newRecord() -> CNRecord
	func record(at row: Int) -> CNRecord?
	func records() -> Array<CNRecord>

	var selectedEvent: CNValueTable.SelectedEvent? { get set }
	var current: CNRecord? { get }

        func select(name nm: String, value val: CNValue) -> Array<CNRecord>

	func append(record rcd: CNRecord)
	func remove(at row: Int) -> Bool

	func forEach(callback cbfunc: (_ record: CNRecord) -> Void)

	func load(value val: Array<CNValue>, from filename: String?) -> NSError?
	func save(to url: URL) -> Bool
}

public extension CNTable
{
	func toValue() -> Array<Dictionary<String, CNValue>> {
		var result: Array<Dictionary<String, CNValue>> = []
		for i in 0..<self.recordCount {
			if let rec = self.record(at: i) {
				result.append(rec.toValue())
			}
		}
		return result
	}

    func toText() -> CNText {
        let result = CNTextSection()
        result.header = "{" ; result.footer = "}"
        for dict in self.toValue() {
            let sec = CNTextSection()
            sec.header = "{" ; sec.footer = "}"
            for (name, val) in dict {
                let subsec = CNTextSection()
                subsec.header = name + " {" ; subsec.footer = "}"
                subsec.add(text: val.toScript())
                sec.add(text: subsec)
            }
            result.add(text: sec)
        }
        return result
    }
}

