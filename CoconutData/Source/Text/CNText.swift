/**
 * @file	CNText.h
 * @brief	Define CNText class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation


public protocol CNText
{
	func append(string src: String)
	func prepend(string src: String)
	func isEmpty() -> Bool
	func toStrings(indent idt: Int) -> Array<String>
}

public extension CNText
{
	func toStrings() -> Array<String> {
		return self.toStrings(indent: 0)
	}

	func indentString(indent idt: Int) -> String {
		var str: String = ""
		for _ in 0..<idt {
			str = str + "  "
		}
		return str
	}
}

private func adjustString(string str: String, length len: Int) -> String {
	var newstr = str
	let rest   = len - str.utf8.count
	for _ in 0..<rest {
		newstr += " "
	}
	return newstr
}

private func split(string src: String) -> Array<String> {
	let lines = src.split(separator: "\n")
	var result: Array<String> = []
	for line in lines {
		result.append(String(line))
	}
	return result
}

public class CNTextLine: CNText
{
	private var mLine:	String

	public init(){
		mLine = ""
	}

	public init(string src: String){
		mLine = src
	}

	public var line: String { get { return mLine }}

	public func set(string src: String){
		mLine = src
	}

	public func append(string src: String){
		mLine += src
	}

	public func prepend(string src: String){
		mLine = src + mLine
	}

	public func isEmpty() -> Bool {
		return mLine.isEmpty
	}

	public var width: Int { get { return mLine.utf8.count }}

	public func toStrings(indent idt: Int) -> Array<String> {
		let spaces = indentString(indent: idt)
		return [ spaces + mLine ]
	}
}

public class CNLabeledText: CNText
{
	public var mLabel:	String
	public var mText:	CNText

	public init(label lab: String, text txt: CNText){
		mLabel	= lab
		mText	= txt
	}

	public func append(string src: String) {
		mText.append(string: src)
	}

	public func prepend(string src: String) {
		mText.prepend(string: src)
	}

	public func isEmpty() -> Bool {
		return mLabel.isEmpty && mText.isEmpty()
	}

	public func toStrings(indent idt: Int) -> Array<String> {
		let bodies = mText.toStrings(indent: 0)

		var result: Array<String> = []
		if bodies.count > 0 {
			/* 1st line */
			result.append(indentString(indent: idt) + mLabel + bodies[0])
			/* Other lines*/
			let idtstr = indentString(indent: idt + 1)
			for i in 1..<bodies.count {
				result.append(idtstr + bodies[i])
			}
		}
		return result
	}
}

public class CNTextList: CNText
{
	private var mItems:	Array<CNText>
	public  var separator:	String

	public init(){
		mItems		= []
		separator	= ""
	}

	public func add(text src: CNText){
		mItems.append(src)
	}

	public func append(string src: String) {
		if let item = mItems.last {
			item.append(string: src)
		} else {
			let line = CNTextLine(string: src)
			mItems.append(line)
		}
	}

	public func insert(text src: CNText, at pos: Int) {
		mItems.insert(src, at: pos)
	}

	public func prepend(string src: String) {
		if mItems.count > 0 {
			mItems[0].prepend(string: src)
		} else {
			let line = CNTextLine(string: src)
			mItems.append(line)
		}
	}

	public func isEmpty() -> Bool {
		return mItems.isEmpty
	}

	public func toStrings(indent idt: Int) -> Array<String> {
		var result: Array<String> = []
		let count = mItems.count
		guard count > 0 else {
			return []
		}
		let idtstr  = indentString(indent: idt)
		let lastidx = count - 1
		for i in 0..<count {
			let substrs = mItems[i].toStrings()
			if substrs.count > 0 {
				for substr in substrs {
					result.append(idtstr + substr)
				}
				if i != lastidx {
					result[result.count - 1] += separator
				}
			}
		}
		return result
	}
}

public class CNTextSection: CNText
{
	public var header: String
	public var footer: String
	public var separator: String?

	private var mContents: Array<CNText>

	public init() {
		self.header	= ""
		self.footer	= ""
		self.separator	= nil
		self.mContents	= []
	}

	public var contentCount: Int { get { return mContents.count }}

	public func add(text src: CNText){
		mContents.append(src)
	}

	public func insert(text src: CNText){
		mContents.insert(src, at: 0)
	}

	public func append(string src: String){
		if let last = mContents.last as? CNTextLine {
			last.append(string: src)
		} else {
			let newtxt = CNTextLine(string: src)
			self.add(text: newtxt)
		}
	}

	public func prepend(string src: String){
		if let first = mContents.first as? CNTextLine {
			first.prepend(string: src)
		} else {
			let newtxt = CNTextLine(string: src)
			self.insert(text: newtxt)
		}
	}

	public func isEmpty() -> Bool {
		return self.header.isEmpty && self.footer.isEmpty && mContents.isEmpty
	}

	public func toStrings(indent idt: Int) -> Array<String> {
		var result: Array<String> = []
		var nextidt = idt

		let spaces = indentString(indent: idt)
		if !self.header.isEmpty {
			result.append(spaces + self.header)
			nextidt += 1
		}
		let cnum = mContents.count
		for c in 0..<cnum {
			let content = mContents[c]
			let lines = content.toStrings(indent: nextidt)
			let lnum  = lines.count
			for i in 0..<lnum {
				var line: String = lines[i]
				/* Insert separator to the end of last line */
				if c < cnum - 1 && i == lnum - 1 {
					if let sep = separator {
						line += sep
					}
				}
				result.append(line)
			}
		}
		if !self.footer.isEmpty {
			result.append(spaces + self.footer)
		}
		return result
	}
}

public class CNTextRecord
{
	private var mColumns: Array<CNTextLine>

	public init(){
		mColumns = []
	}

	public var columnCount: Int { get { return mColumns.count }}

	public var columns: Array<CNTextLine> {
		get { return mColumns }
	}

	public func append(string src: String) {
		append(line: CNTextLine(string: src))
	}

	public func append(line src: CNTextLine) {
		mColumns.append(src)
	}

	public func prepend(string src: String) {
		mColumns.insert(CNTextLine(string: src), at: 0)
	}

	public func prepend(line src: CNTextLine) {
		mColumns.insert(src, at: 0)
	}

	public var widths: Array<Int> { get {
		var result: Array<Int> = []
		mColumns.forEach({
			(_ column: CNTextLine) -> Void in
			result.append(column.width)
		})
		return result
	}}

	public func toStrings(widths widthvals: Array<Int>) -> Array<String> {
		var line: String = ""
		for cindex in 0..<mColumns.count {
			let column = mColumns[cindex]
			let colstr = column.line
			line += adjustString(string: colstr, length: widthvals[cindex] + 1)
		}
		return [line]
	}
}

public class CNTextTable: CNText
{
	public var mRecords: Array<CNTextRecord>

	public init(){
		mRecords = []
	}

	public var count: Int { get { return mRecords.count }}

	public var records: Array<CNTextRecord> {
		get		{ return mRecords }
		set(recs)	{ mRecords = recs }
	}

	public func add(record src: CNTextRecord) {
		mRecords.append(src)
	}

	public func insert(record src: CNTextRecord){
		mRecords.insert(src, at: 0)
	}

	public func append(string src: String) {
		if mRecords.count > 0 {
			mRecords[mRecords.count - 1].append(string: src)
		} else {
			let newrec = CNTextRecord()
			newrec.append(string: src)
			mRecords.append(newrec)
		}
	}

	public func prepend(string src: String) {
		if mRecords.count > 0 {
			mRecords[mRecords.count - 1].prepend(string: src)
		} else {
			let newrec = CNTextRecord()
			newrec.prepend(string: src)
			mRecords.append(newrec)
		}
	}

	public func isEmpty() -> Bool {
		return mRecords.isEmpty
	}

	public var maxColumnCount: Int { get {
		var result: Int = 0
		mRecords.forEach({
			(_ rec: CNTextRecord) -> Void in
			result = max(result, rec.columnCount)
		})
		return result
	}}

	public func toStrings(indent idt: Int) -> Array<String> {
		/* Get max column num */
		let maxcolnum = self.maxColumnCount

		/* Initialize column width */
		var widths: Array<Int> = Array(repeating: 0, count: maxcolnum)

		/* Get max width for each column */
		mRecords.forEach({
			(_ rec: CNTextRecord) -> Void in
			for i in 0..<rec.columnCount {
				let col  = rec.columns[i]
				widths[i] = max(widths[i], col.width)
			}
		})

		/* make lines */
		let spaces = indentString(indent: idt)
		var results: Array<String> = []
		mRecords.forEach({
			(_ rec: CNTextRecord) -> Void in
			let lines = rec.toStrings(widths: widths)
			for line in lines {
				results.append(spaces + line)
			}
		})
		return results
	}
}





