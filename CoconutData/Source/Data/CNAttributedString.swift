/**
 * @file	CNAttributedString.swift
 * @brief	Extend NSAttributedString class
 * @par Copyright
 *   Copyright (C) 2019-2021 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import Foundation

public extension NSAttributedString
{
	convenience init(string str: String, font fnt: CNFont) {
		let attrs: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font:		fnt
		]
		self.init(string: str, attributes: attrs)
	}

	convenience init(string str: String, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		let newfont = CNFontManager.shared.convert(font: fnt, terminalInfo: terminfo)

		let fcol = terminfo.doReverse ? terminfo.backgroundColor : terminfo.foregroundColor
		let bcol = terminfo.doReverse ? terminfo.foregroundColor : terminfo.backgroundColor
		var attrs: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.foregroundColor: fcol,
			NSAttributedString.Key.backgroundColor:	bcol,
			NSAttributedString.Key.font:		newfont
		]
		if terminfo.doUnderline {
			attrs[NSAttributedString.Key.underlineStyle] = NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue)
		}
		self.init(string: str, attributes: attrs)
	}

	func character(at index: Int) -> Character? {
		let str = self.string
		if index < str.count {
			let idx = str.index(str.startIndex, offsetBy: index)
			return str[idx]
		}
		return nil
	}

	func lineCount(from start: Int, to end: Int) -> Int {
		let str    = self.string
		let last   = str.endIndex
		var idx    = str.index(str.startIndex, offsetBy: start)
		var diff   = end - start
		var result = 0
		while idx < last && diff > 0 {
			if str[idx].isNewline {
				result += 1
			}
			idx   = str.index(after: idx)
			diff -= 1
		}
		return result
	}

	func lineCountFromCursorToTextStart(from index: Int) -> Int {
		let str    = self.string
		let start  = str.startIndex
		var idx    = str.index(start, offsetBy: index)
		var result = 0
		while start < idx {
			let prev = str.index(before: idx)
			if str[prev].isNewline {
				result += 1
			}
			idx = prev
		}
		return result
	}

	func lineCountFromCursorToTextEnd(from index: Int) -> Int {
		let str    = self.string
		let end    = str.endIndex
		var idx    = str.index(str.startIndex, offsetBy: index)
		var result = 0
		while idx < end {
			if str[idx].isNewline {
				result += 1
			}
			idx = str.index(after: idx)
		}
		return result
	}

	func distanceFromLineStart(to index: Int) -> Int {
		var result = 0
		let str    = self.string
		var idx    = str.index(str.startIndex, offsetBy: index)
		let start  = str.startIndex
		while start < idx {
			let prev = str.index(before: idx)
			if str[prev].isNewline {
				break
			}
			idx     = prev
			result += 1
		}
		return result
	}

	func distanceToLineEnd(from index: Int) -> Int {
		var result = 0
		let str    = self.string
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		while idx < end {
			if str[idx].isNewline {
				break
			}
			idx     = str.index(after: idx)
			result += 1
		}
		return result
	}

	func moveCursorForward(from index: Int) -> Int? {
		let str = self.string
		let idx = str.index(str.startIndex, offsetBy: index)
		let end = str.endIndex
		if idx < end {
			if !str[idx].isNewline {
				return index + 1
			}
		}
		return nil
	}

	func moveCursorForward(from index: Int, number num: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		for _ in 0..<num {
			if idx < end {
				if str[idx].isNewline {
					break
				}
				idx = str.index(after: idx)
				result += 1
			} else {
				break
			}
		}
		return result
	}

	func moveCursorToLineEnd(from index: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		while idx < end {
			if str[idx].isNewline {
				break
			}
			idx = str.index(after: idx)
			result += 1
		}
		return result
	}

	func moveCursorToTextEnd(from index: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let end    = str.endIndex
		while idx < end {
			idx = str.index(after: idx)
			result += 1
		}
		return result
	}

	func moveCursorBackward(from index: Int) -> Int? {
		let str   = self.string
		let idx   = str.index(str.startIndex, offsetBy: index)
		let start = str.startIndex
		if start < idx {
			let prev = str.index(before: idx)
			if !str[prev].isNewline {
				return index - 1
			}
		}
		return nil
	}

	func moveCursorBackward(from index: Int, number num: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let start  = str.startIndex
		for _ in 0..<num {
			if start < idx {
				let prev = str.index(before: idx)
				if str[prev].isNewline {
					break
				}
				result -= 1
				idx     = prev
			} else {
				break
			}
		}
		return result
	}

	func moveCursorToLineStart(from index: Int) -> Int {
		let str    = self.string
		var result = index
		var idx    = str.index(str.startIndex, offsetBy: index)
		let start  = str.startIndex
		while start < idx {
			let prev = str.index(before: idx)
			if str[prev].isNewline {
				break
			}
			result -= 1
			idx     = prev
		}
		return result
	}

	func moveCursorToTextStart(from index: Int) -> Int {
		return 0
	}

	func moveCursorToPreviousLineEnd(from index: Int) -> Int? {
		/* Move to line head */
		let head = moveCursorToLineStart(from: index)
		/* Skip previous newline */
		if 0 < head {
			return head - 1
		} else {
			return nil
		}
	}

	func moveCursorToNextLineStart(from index: Int) -> Int? {
		/* Move to line end */
		let tail = moveCursorToLineEnd(from: index)
		/* Skip next newline */
		if tail < self.string.count {
			let next = tail + 1
			if next < self.string.count {
				return next
			}
		}
		return nil
	}

	func moveCursorToPreviousLineStart(from index: Int, number num: Int) -> Int {
		var curidx = index
		for _ in 0..<num {
			if let newidx = moveCursorToPreviousLineEnd(from: curidx) {
				curidx = newidx
			} else {
				break
			}
		}
		return moveCursorToLineStart(from: curidx)
	}

	func moveCursorToNextLineStart(from index: Int, number num: Int) -> (Int, Bool) {
		var curidx    = index
		var donewline = false
		for _ in 0..<num {
			if let newidx = moveCursorToNextLineStart(from: curidx) {
				curidx = newidx
			} else {
				donewline = true
				break
			}
		}
		return (curidx, donewline)
	}

	func moveCursorUpOrDown(from idx: Int, doUp doup: Bool, number num: Int) -> Int {
		var ptr   = idx
		/* Keep holizontal offset */
		let orgoff = self.distanceFromLineStart(to: ptr)
		/* up/down num lines */
		if doup {
			for _ in 0..<num {
				if let newptr = moveCursorToPreviousLineEnd(from: ptr) {
					ptr = newptr
				} else {
					break
				}
			}
		} else {
			for _ in 0..<num {
				if let newptr = moveCursorToNextLineStart(from: ptr) {
					ptr = newptr
				} else {
					break
				}
			}
		}
		/* get current offset */
		let curoff = self.distanceFromLineStart(to: ptr)
		/* adjust holizontal offset */
		if curoff < orgoff {
			ptr = moveCursorForward(from: ptr, number: orgoff - curoff)
		} else if orgoff < curoff {
			ptr = moveCursorBackward(from: ptr, number: curoff - orgoff)
		}
		return ptr
	}

	func moveCursorTo(from index: Int, x xpos: Int) -> Int {
		var result: Int
		let hoff = self.distanceFromLineStart(to: index)
		if hoff < xpos {
			result = moveCursorForward(from: index, number: xpos - hoff)
		} else if hoff > xpos {
			result = moveCursorBackward(from: index, number: hoff - xpos)
		} else {
			result = index
		}
		return result
	}

	func moveCursorTo(x xpos: Int, y ypos: Int) -> Int {
		var newidx: Int = 0
		/* Move for Y */
		if ypos > 0 {
			let (next, _) = moveCursorToNextLineStart(from: newidx, number: ypos)
			newidx = next
		}
		if xpos > 0 {
			newidx = moveCursorForward(from: newidx, number: xpos)
		}
		return newidx
	}

	var foregroundColor: CNColor? { get {
		let attr = self.attributes(at: 0, effectiveRange: nil)
		if let col = attr[NSAttributedString.Key.foregroundColor] as? CNColor {
			return col
		} else {
			return nil
		}
	}}

	var backgroundColor: CNColor? { get {
		let attr = self.attributes(at: 0, effectiveRange: nil)
		if let col = attr[NSAttributedString.Key.backgroundColor] as? CNColor {
			return col
		} else {
			return nil
		}
	}}
}

public extension NSMutableAttributedString
{
	func write(string str: String, at index: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> Int {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		/* Get length to replace */
		let restlen  = self.distanceToLineEnd(from: index)
		let replen   = min(restlen, str.count)
		if replen > 0 {
			self.delete(from: index, length: replen)
		}
		/* Insert new string */
		self.insert(astr, at: index)
		return index + str.count
	}

	func insert(string str: String, at index: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> Int {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.insert(astr, at: index)
		return index
	}

	func delete(at index: Int, number num: Int) -> Int {
		let newidx = self.moveCursorBackward(from: index, number: num)
		let delta  = index - newidx
		if delta > 0 {
			self.delete(from: newidx, length: delta)
			return newidx
		} else {
			return index
		}
	}

	func append(string str: String, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) -> Int {
		let astr = NSAttributedString(string: str, font: fnt, terminalInfo: terminfo)
		self.append(astr)
		return self.string.count
	}

	func clear(font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		/* Clear normally */
		let range = NSRange(location: 0, length: self.string.count)
		self.deleteCharacters(in: range)
		if terminfo.isAlternative {
			/* Fill by spaces */
			let space    = String(repeating: " ", count: terminfo.width)
			let aspace   = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
			let anewline = NSAttributedString(string: "\n", font: fnt, terminalInfo: terminfo)
			for i in 0..<terminfo.height {
				if i > 0 { self.append(anewline) }
				self.append(aspace)
			}
		}
	}

	func deleteForwardCharacters(from index: Int, number num: Int) -> Int {
		let lineend  = self.moveCursorForward(from: index, number: num)
		delete(from: index, to: lineend)
		return index
	}

	func deleteFromCursorToLineEnd(from index: Int) -> Int {
		let lineend  = self.moveCursorToLineEnd(from: index)
		delete(from: index, to: lineend)
		return index
	}

	func deleteFromCursorToTextEnd(from index: Int) -> Int {
		let lineend  = self.moveCursorToTextEnd(from: index)
		delete(from: index, to: lineend)
		return index
	}

	func deleteBackwardCharacters(from index: Int, number num: Int) -> Int {
		let linestart = self.moveCursorBackward(from: index, number: num)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteFromCursorToLineStart(from index: Int) -> Int {
		let linestart = self.moveCursorToLineStart(from: index)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteFromCursorToTextStart(from index: Int) -> Int {
		let linestart = self.moveCursorToTextStart(from: index)
		delete(from: linestart, to: index)
		return linestart
	}

	func deleteEntireLine(from index: Int) -> Int {
		var linestart = self.moveCursorToLineStart(from: index)
		var lineend   = self.moveCursorToLineEnd(from: index)
		if linestart > 0 {
			if let c = self.character(at: linestart - 1) {
				if c.isNewline {
					linestart -= 1
				}
			}
		} else if lineend < self.string.count - 1 {
			if let c = self.character(at: lineend + 1) {
				if c.isNewline {
					lineend += 1
				}
			}
		}
		if linestart < lineend {
			delete(from: linestart, to: lineend)
		}
		return linestart
	}

	private func delete(from fromidx: Int, to toidx: Int) {
		let len = toidx - fromidx
		if len > 0 {
			let range = NSRange(location: fromidx, length: len)
			self.deleteCharacters(in: range)
		}
	}

	private func delete(from fromidx: Int, length len: Int) {
		if len > 0 {
			let range = NSRange(location: fromidx, length: len)
			self.deleteCharacters(in: range)
		}
	}

	func changeOverallFont(font newfont: CNFont){
		let entire = NSMakeRange(0, self.string.count)
		self.enumerateAttribute(.font, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			removeAttribute(.font, range: entire)
			addAttribute(.font, value: newfont, range: entire)
		})
	}

	func resize(width newwidth: Int, height newheight: Int, font fnt: CNFont, terminalInfo terminfo: CNTerminalInfo) {
		var ptr	  = 0
		var pos   = 0
		var lines = 0
		while ptr < self.string.count {
			let len = self.distanceToLineEnd(from: ptr)
			if len > newwidth {
				/* Cut line */
				ptr = deleteBackwardCharacters(from: ptr, number: len - newwidth)
			} else if len < newwidth {
				/* Fill line */
				let space = String(repeating: "_", count: newwidth - len)
				let astr  = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
				self.insert(astr, at: pos + len)
			}
			if let next = moveCursorToNextLineStart(from: ptr) {
				ptr   =  next
				pos   += newwidth + 1 // +1 for new line
			} else {
				ptr   =  self.string.count
				pos   += len
			}
			lines += 1

			if lines > newheight {
				/* Remove rest strings */
				if ptr < self.string.count {
					let head  = ptr
					let total = self.string.count
					let range = NSRange(location: head, length: total - head)
					self.deleteCharacters(in: range)
				}
			}
		}
		if lines < newheight {
			let space    = String(repeating: "_", count: newwidth)
			let aspace   = NSAttributedString(string: space, font: fnt, terminalInfo: terminfo)
			let anewline = NSAttributedString(string: "\n", font: fnt, terminalInfo: terminfo)
			for _ in lines..<newheight {
				self.append(aspace)
				self.append(anewline)
			}
		}
	}

	func setOverallTextColor(color newcol: CNColor?){
		self.setOverallTextColor(attribute: .foregroundColor, color: newcol)
	}

	func setOverallBackgroundColor(color newcol: CNColor?){
		self.setOverallTextColor(attribute: .backgroundColor, color: newcol)
	}

	private func setOverallTextColor(attribute key: NSAttributedString.Key, color newcol: CNColor?){
		/* Remove current attributes */
		let entire = NSMakeRange(0, self.string.count)
		self.enumerateAttribute(key, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			removeAttribute(key, range: range)
		})
		/* Set new range */
		if let col = newcol {
			self.addAttributes([key: col], range: entire)
		}
	}

	func changeOverallTextColor(targetColor curcol: CNColor, newColor newcol: CNColor){
		let entire = NSMakeRange(0, self.string.count)
		self.enumerateAttribute(.foregroundColor, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			/* Replace current foreground color attribute by new color */
			if let colobj = anyobj as? CNColor {
				if colobj.isEqual(curcol) {
					removeAttribute(.foregroundColor, range: range)
					addAttribute(.foregroundColor, value: newcol, range: range)
				}
			}
		})
	}

	func changeOverallBackgroundColor(targetColor curcol: CNColor, newColor newcol: CNColor){
		let entire = NSMakeRange(0, self.string.count)
		self.enumerateAttribute(.backgroundColor, in: entire, options: [], using: {
			(anyobj, range, unsage) -> Void in
			/* Replace current background color attribute by new color */
			if let colobj = anyobj as? CNColor {
				if colobj.isEqual(curcol) {
					removeAttribute(.backgroundColor, range: range)
					addAttribute(.backgroundColor, value: newcol, range: range)
				}
			}
		})
	}
}
