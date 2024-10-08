/**
 * @file	CNStringUtil.swift
 * @brief	Define CNStringUtil class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif

public extension String
{
	var isWhiteSpace: Bool { get {
		var idx = self.startIndex
		let end = self.endIndex
		while idx < end {
			if !self[idx].isWhitespace {
				return false
			}
			idx = self.index(after: idx)
		}
		return (idx >= end)
	}}

	var isNumber: Bool { get {
		var idx = self.startIndex
		let end = self.endIndex
		while idx < end {
			if !self[idx].isNumber {
				return false
			}
			idx = self.index(after: idx)
		}
		return (idx >= end)
	}}

	/* Reference: /https://stackoverflow.com/questions/35992800/check-if-a-string-is-alphanumeric-in-swift */
	var isAlphaNumerics: Bool { get {
		return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
	}}

	var isIdentifier: Bool { get {
		var idx = self.startIndex
		let end = self.endIndex
		while idx < end {
			let c = self[idx]
			if !(c.isIdentifier) {
				return false
			}
			idx = self.index(after: idx)
		}
		return (idx >= end)
	}}

	static func stringFromData(data dat: Data) -> String? {
		if let str = String(data: dat, encoding: .utf8) {
			return str.precomposedStringWithCanonicalMapping
		}
		return nil
	}

	var deletingPathExtension: String {
		let nsstr  = self as NSString
		let result = nsstr.deletingPathExtension
		return result as String
	}

	func pad(char c: Character, toLength len: Int, align algn: NSTextAlignment) -> String {
		let curlen = self.count
		let diff   = len - curlen
		if diff > 0 {
			let newstr: String
			switch algn {
			case .left, .natural, .justified:
				newstr = self + String(repeating: " ", count: diff)
			case .right:
				newstr = String(repeating: " ", count: diff) + self
			case .center:
				let hdiff = diff / 2
				newstr = String(repeating: " ", count: hdiff)
					 + self
					 + String(repeating: " ", count: diff - hdiff)
			@unknown default:
				newstr = self + String(repeating: " ", count: diff)
			}
			return newstr
		} else {
			return self
		}
	}

    func toString() -> String {
        return self
    }
}

public class CNStringUtil
{
	public class func insertEscapeForQuote(source src: String) -> String {
		let stream     = CNStringStream(string: src)
		var result     = ""
		var didescaped = false
		while let c = stream.getc() {
			switch c {
			case "\"":
				result.append("\\")
				result.append(c)
				didescaped = false
			case "\\":
				didescaped = true		// escape is skipped
			default:
				if didescaped {
					result.append("\\")
					didescaped = false
				}
				result.append(c)
			}
		}
		if didescaped { // last escape
			result.append("\\")
			didescaped = false
		}
		return result
	}

	public class func removeEscapeForQuote(source strm: CNStringStream) -> Result<String, NSError> {
		let _ = strm.getc() // drop first "
		var result      = ""
		var didescaped  = false
		var didfinished = false
		loop: while let c = strm.getc() {
			switch c {
			case "\\":
				didescaped = true
			case "\"":
				if didescaped {
					result.append(c)
					didescaped = false
				} else {
					didfinished = true
					break loop
				}
			default:
				if didescaped {
					result.append("\\")
					didescaped = false
				}
				result.append(c)
			}
		}
		if didfinished {
			return .success(result)
		} else {
			return .failure(NSError.parseError(message: "'\"' is NOT found to close the string near \"\(result)\""))
		}
	}

    /* If the source strem has started by spaces and "//", this method returns true */
    public class func isCommentString(source src: String) -> Bool {
        let strm = CNStringStream(string: src)
        strm.skipspaces()
        if let c0 = strm.getc() {
            if c0 == "/" {
                if let c1 = strm.getc() {
                    if c1 == "/" {
                        return true
                    }
                }
            }
        }
        return false
    }

	public class func divideByQuote(sourceString src: String, quote qchar: Character) -> Array<String>
	{
		var result: Array<String> = []
		var curstr: String        = ""
		var inquote: Bool 	  = false

		let stream = CNStringStream(string: src)
		while let c = stream.getc() {
			if c == "\\" {
				if let n = stream.getc() {
					if n == qchar {
						curstr.append(n)
					} else {
						curstr.append(c)
						curstr.append(n)
					}
				} else {
					curstr.append(c)
				}
			} else if c == qchar {
				let substrs = divideBySpace(inQuote: inquote, string: curstr)
				result.append(contentsOf: substrs)
				inquote = !inquote
				curstr = ""
			} else {
				curstr.append(c)
			}
		}
		let substrs = divideBySpace(inQuote: inquote, string: curstr)
		result.append(contentsOf: substrs)
		curstr = ""
		return result
	}

	public class func divideBySpaces(string src: String) -> Array<String> {
		var result: Array<String> = []
		var headidx = src.startIndex
		var curidx  = headidx
		let endidx  = src.endIndex
		while curidx < endidx {
			let c = src[curidx]
			if c.isWhitespace {
				/* flush current word */
				if headidx < curidx {
					let word = src[headidx..<curidx]
					result.append(String(word))
				}
				headidx = src.index(after: curidx)
				curidx  = headidx
			} else {
				curidx  = src.index(after: curidx)
			}
		}
		/* flush current word */
		if headidx < curidx {
			let word = src[headidx..<curidx]
			result.append(String(word))
			headidx = curidx
		}
		return result
	}

	private class func divideBySpace(inQuote inquote: Bool, string src: String) -> Array<String> {
		if src == "" {
			return []
		} else if inquote {
			return [src]
		} else {
			return src.components(separatedBy: CharacterSet.whitespaces).filter{ $0.count > 0 }
		}
	}

	public class func spacePrefix(string str: String) -> String {
		var spaces: String = ""
		let start = str.startIndex
		let end   = str.endIndex
		var idx   = start
		while idx < end {
			let c = str[idx]
			if c==" " || c=="\t" {
				spaces.append(c)
			} else {
				break
			}
			idx = str.index(after: idx)
		}
		return spaces
	}

	public class func traceForward(string str: String, pointer ptr: String.Index, doSkipFunc skip: (Character) -> Bool) -> String.Index {
		let end   = str.endIndex
		var idx   = ptr
		while idx < end {
			if skip(str[idx]) {
				idx = str.index(after: idx)
			} else {
				break
			}
		}
		return idx
	}

	public class func traceBackward(string str: String, pointer ptr: String.Index, doSkipFunc skip: (Character) -> Bool) -> String.Index {
		let start   = str.startIndex
		var curidx  = ptr
		if start < curidx {
			var previdx = str.index(before: curidx)
			while start < previdx {
				if skip(str[previdx]) {
					curidx  = previdx
					previdx = str.index(before: curidx)
				} else {
					break
				}
			}
		}
		return curidx
	}

	public class func skipHeadingSpaces(string str: String) -> String {
		var idx = str.startIndex
		let end = str.endIndex
		if idx < end {
			/* Skip space character */
			while idx < end {
				if str[idx].isWhitespace {
					idx = str.index(after: idx)
				} else {
					break
				}
			}
			return String(str[idx..<end])
		} else {
			return str
		}
	}

	public class func removingTailSpaces(string str: String) -> String {
		var result = str
		while !result.isEmpty {
			if let c = result.last {
				if c.isWhitespace {
					result.removeLast()
				} else {
					break
				}
			} else {
				break
			}
		}
		return result
	}

	public class func removingSideSpaces(string str: String) -> String {
		let str1 = skipHeadingSpaces(string: str)
		return removingTailSpaces(string: str1)
	}

	public class func cutFirstWord(string str: String) -> (String?, String?) {
		let mstr = skipHeadingSpaces(string: str)
		let head = mstr.startIndex
		let end  = mstr.endIndex
		var ptr  = head
		if ptr < end {
			/* Skip non space */
			while ptr < end {
				if !mstr[ptr].isWhitespace {
					ptr = mstr.index(after: ptr)
				} else {
					let headstr = String(mstr[head..<ptr])
					let tailstr = String(mstr[ptr..<end])
					return (headstr, skipHeadingSpaces(string: tailstr))
				}
			}
			/* Can not be divided */
			return (mstr, nil)
		} else {
			return (nil, nil)
		}
	}
}
