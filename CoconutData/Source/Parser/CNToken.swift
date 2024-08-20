/**
 * @file	CNToken.swift
 * @brief	Define CNToken class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public enum CNTokenType
{
	case ReservedWordToken(Int)
	case SymbolToken(Character)
	case IdentifierToken(String)
	case BoolToken(Bool)
	case UIntToken(UInt)
	case IntToken(Int)
	case DoubleToken(Double)
	case StringToken(String)
	case TextToken(String)
	case CommentToken(String)

    public func code(withComment withcom: Bool) -> String {
        let result: String
        switch self {
        case .ReservedWordToken(let val):
            result = "\(val)"
        case .SymbolToken(let val):
            result = "\(val)"
        case .IdentifierToken(let val):
            result = val
        case .BoolToken(let val):
            result = "\(val)"
        case .IntToken(let val):
            result = "\(val)"
        case .UIntToken(let val):
            result = "\(val)"
        case .DoubleToken(let val):
            result = "\(val)"
        case .StringToken(let val):
            result = "\"\(val)\""
        case .TextToken(let val):
            result = "%{ \(val) %}"
        case .CommentToken(let val):
            result = withcom ? "// \(val)" : ""
        }
        return result
    }
}

/* Used as enum in TypeScript/JavaScript */
public enum CNTokenId: Int
{
	public static let TypeName = "TokenType"

	case reservedWord	= 0
	case symbol		    = 1
	case identifier		= 2
	case bool		    = 3
	case int	    	= 4
	case float		    = 5
	case text		    = 6
    case comment        = 7

	public static let enumTypes: Dictionary<String, Int> = [
		"reservedWord":		CNTokenId.reservedWord.rawValue,
		"symbol":		    CNTokenId.symbol.rawValue,
		"identifier":		CNTokenId.identifier.rawValue,
		"bool":			    CNTokenId.bool.rawValue,
		"int":			    CNTokenId.int.rawValue,
		"float":		    CNTokenId.float.rawValue,
		"text":			    CNTokenId.text.rawValue,
        "comment":          CNTokenId.comment.rawValue
	]

	public static func allocateEnumType() -> CNEnumType {
		let tokenid = CNEnumType(typeName: CNTokenId.TypeName)
		for (key, val) in CNTokenId.enumTypes {
			tokenid.add(name: key, value: .intValue(val))
		}
		return tokenid
	}

	public static func from(tokenType type: CNTokenType) -> CNTokenId {
		let result: CNTokenId
		switch type {
		case .ReservedWordToken(_):	result = .reservedWord
		case .SymbolToken(_):		result = .symbol
		case .IdentifierToken(_):	result = .identifier
		case .BoolToken(_):		    result = .bool
		case .UIntToken(_):		    result = .int
		case .IntToken(_):		    result = .int
		case .DoubleToken(_):		result = .float
		case .StringToken(_):		result = .text
		case .TextToken(_):		    result = .text
		case .CommentToken(_):		result = .comment
		}
		return result
	}
}

public struct CNToken
{
	public static let InterfaceName = "TokenIF"

	private var mType:	CNTokenType
	private var mLineNo:	Int

	public init(type t: CNTokenType, lineNo no: Int){
		mType   = t
		mLineNo = no
	}

	/* Interface for TypeScript/JavaScript */
	static func allocateInterfaceType() -> CNInterfaceType {
		let tokentyp = CNTokenId.allocateEnumType()
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "type",		type: .enumType(tokentyp)),
			M(name: "lineNo",	type: .numberType),
			M(name: "reservedWord",	type: .functionType(.nullable(.numberType),	[])),
			M(name: "symbol",	type: .functionType(.nullable(.stringType),	[])),
			M(name: "identifier",	type: .functionType(.nullable(.stringType),	[])),
			M(name: "bool",		type: .functionType(.nullable(.boolType),	[])),
			M(name: "int",		type: .functionType(.nullable(.numberType),	[])),
			M(name: "float",	type: .functionType(.nullable(.numberType),	[])),
			M(name: "text",		type: .functionType(.nullable(.stringType),	[]))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	public var type: CNTokenType { return mType }
	public var lineNo: Int { return mLineNo }

    public func code(withComment withcomm: Bool) -> String {
		return mType.code(withComment: withcomm)
	}

	public func getReservedWord() -> Int? {
		let result: Int?
		switch self.type {
		case .ReservedWordToken(let val):
			result = val
		default:
			result = nil
		}
		return result
	}

	public func getSymbol() -> Character? {
		let result: Character?
		switch self.type {
		case .SymbolToken(let c):
			result = c
		default:
			result = nil
		}
		return result
	}

	public func getIdentifier() -> String? {
		let result: String?
		switch self.type {
		case .IdentifierToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}

	public func getBool() -> Bool? {
		let result: Bool?
		switch self.type {
		case .BoolToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getInt() -> Int? {
		let result: Int?
		switch self.type {
		case .IntToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getUInt() -> UInt? {
		let result: UInt?
		switch self.type {
		case .UIntToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getDouble() -> Double? {
		let result: Double?
		switch self.type {
		case .DoubleToken(let v):
			result = v
		default:
			result = nil
		}
		return result
	}

	public func getNumber() -> NSNumber? {
		let result: NSNumber?
		switch self.type {
		case .DoubleToken(let v):
			result = NSNumber(value: v)
		case .UIntToken(let v):
			result = NSNumber(value: v)
		case .IntToken(let v):
			result = NSNumber(value: v)
		default:
			result = nil
		}
		return result
	}

	public func getString() -> String? {
		let result: String?
		switch self.type {
		case .StringToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}

	public func getText() -> String? {
		let result: String?
		switch self.type {
		case .TextToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}

	public func getComment() -> String? {
		let result: String?
		switch self.type {
		case .CommentToken(let s):
			result = s
		default:
			result = nil
		}
		return result
	}
}

public func CNStringToToken(string srcstr: String, config conf: CNParserConfig) -> Result<Array<CNToken>, NSError>
{
    let tokenizer = CNTokenizer(config: conf)
    switch tokenizer.tokenize(string: srcstr) {
    case .success(let tokens):
        if conf.ignoreComments {
            return .success(removeComments(tokens: tokens))
        } else {
            return .success(tokens)
        }
    case .failure(let err):
        return .failure(err)
    }
}

public func CNStringStreamToToken(stream srcstrm: CNStringStream, config conf: CNParserConfig) -> Result<Array<CNToken>, NSError>
{
	let tokenizer = CNTokenizer(config: conf)
    switch tokenizer.tokenize(stream: srcstrm) {
    case .success(let tokens):
        if conf.ignoreComments {
            return .success(removeComments(tokens: tokens))
        } else {
            return .success(tokens)
        }
    case .failure(let err):
        return .failure(err)
    }
}

private func removeComments(tokens tkns: Array<CNToken>) -> Array<CNToken>
{
    var result: Array<CNToken> = []
    for token in tkns {
        switch token.type {
        case .CommentToken(_):
            break
        default:
            result.append(token)
        }
    }
    return result
}

private class CNTokenizer
{
	var mConfig:		CNParserConfig
	var mCurrentLine:	Int

	public init(config conf: CNParserConfig){
		mConfig		= conf
		mCurrentLine	= 1
	}

    public func tokenize(string srcstr: String) -> Result<Array<CNToken>, NSError> {
        let stream  = CNStringStream(string: srcstr)
        return tokenize(stream: stream)
	}

	public func tokenize(stream srcstrm: CNStringStream) -> Result<Array<CNToken>, NSError> {
        switch stringToTokens(stream: srcstrm) {
        case .success(let tokens):
            return .success(tokens)
        case .failure(let err):
            return .failure(err)
        }
	}

	private func stringToTokens(stream srcstream: CNStringStream) -> Result<Array<CNToken>, NSError> {
		mCurrentLine = 1
		var result : Array<CNToken> = []
		while true {
			skipSpaces(stream: srcstream)
			if srcstream.eof() {
				break
			}
            switch getTokenFromStream(stream: srcstream) {
            case .success(let token):   result.append(token)
            case .failure(let err):     return .failure(err)
            }
		}
        return .success(result)
	}

	private func getTokenFromStream(stream srcstream: CNStringStream) -> Result<CNToken, NSError> {
		if let c1 = srcstream.peek(offset: 0) {
			if c1 == "0" {
				if let c2 = srcstream.peek(offset: 1) {
					switch c2 {
					case ".":
						return getDigitTokenFromStream(stream: srcstream)
					case "x", "X":
						return getHexTokenFromStream(stream: srcstream)
					default:
						let _ = srcstream.getc() // drop 1st character
						let token = CNToken(type: .UIntToken(0), lineNo: mCurrentLine)
                        return .success(token)
					}
				} else {
					let _ = srcstream.getc() // drop 1st character
					let token = CNToken(type: .UIntToken(0), lineNo: mCurrentLine)
                    return .success(token)
				}
			} else if c1.isNumber {
				return getDigitTokenFromStream(stream: srcstream)
			} else if c1.isLetter || c1 == "_" {
				return getIdentifierTokenFromStream(stream: srcstream)
			} else if c1 == "\"" {
				return getStringTokenFromStream(stream: srcstream)
			} else if c1 == "%" {
				if let c2 = srcstream.peek(offset: 1) {
					switch c2 {
					case "{":
						return getTextTokenFromStream(stream: srcstream)
					default:
						let _ = srcstream.getc() // drop 1st character
						let token = CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
                        return .success(token)
					}
				} else {
					let _ = srcstream.getc() // drop 1st character
					let token = CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
                    return .success(token)
				}
			} else if c1 == "/" {
				if let c2 = srcstream.peek(offset: 1) {
					if c2 == "/" {
						let token = getCommentFromStream(stream: srcstream)
                        return .success(token)
					}
				}
				let _ = srcstream.getc() // drop 1st character
				let token = CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
                return .success(token)
			} else {
				let _ = srcstream.getc() // drop 1st character
				let token = CNToken(type: .SymbolToken(c1), lineNo: mCurrentLine)
                return .success(token)
			}
		} else {
			fatalError("Can not reach here: srcrange=\(srcstream.description)")
		}
	}

	private func skipSpaces(stream srcstream: CNStringStream) {
		while true {
			if let c = srcstream.getc() {
				if !c.isWhitespace {
					let _ = srcstream.ungetc()
					break
				} else if c.isNewline {
					mCurrentLine += 1
				}
			} else {
				break
			}
		}
	}

	private func getDigitTokenFromStream(stream srcstream: CNStringStream) -> Result<CNToken, NSError> {
		var hasperiod = false
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if c.isNumber {
				return true
			} else if c == "." {
				hasperiod = true
				return true
			} else {
				return false
			}
		})
		if hasperiod {
			if let value = Double(resstr) {
                return .success(CNToken(type:.DoubleToken(value), lineNo: mCurrentLine))
			} else {
				let err = NSError.parseError(message: "Double value is expected but \"\(resstr)\" is given", location: #function)
                return .failure(err)
			}
		} else {
			if let value = UInt(resstr, radix: 10) {
                return .success(CNToken(type: .UIntToken(value), lineNo: mCurrentLine))
			} else {
				let err = NSError.parseError(message: "Integer value is expected but \"\(resstr)\" is given", location: #function)
                return .failure(err)
			}
		}
	}

	private func getHexTokenFromStream(stream srcstream: CNStringStream) -> Result<CNToken, NSError> {
		let _ = srcstream.gets(count: 2) // drop first "0x"
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if c.isHexDigit {
				return true
			} else {
				return false
			}
		})
		if let value = UInt(resstr, radix: 16) {
            return .success(CNToken(type: .UIntToken(value), lineNo: mCurrentLine))
		} else {
			let err = NSError.parseError(message: "Hex integer value is expected but \"\(resstr)\" is given at \(mCurrentLine)", location: #function)
            return .failure(err)
		}
	}

	private func getIdentifierTokenFromStream(stream srcstream: CNStringStream) -> Result<CNToken, NSError> {
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			return c.isLetterOrNumber || c == "_" || (mConfig.allowIdentiferHasPeriod && c == ".")
		})
		let lresstr = resstr.lowercased()
		if lresstr == "true"{
            return .success(CNToken(type: .BoolToken(true), lineNo: mCurrentLine))
		} else if lresstr == "false" {
            return .success(CNToken(type: .BoolToken(false), lineNo: mCurrentLine))
		} else {
            return .success(CNToken(type: .IdentifierToken(resstr), lineNo: mCurrentLine))
		}
	}

    private func getStringTokenFromStream(stream srcstream: CNStringStream) -> Result<CNToken, NSError> {
        switch CNStringUtil.removeEscapeForQuote(source: srcstream) {
        case .success(let str):
            return .success(CNToken(type: .StringToken(str), lineNo: mCurrentLine))
        case .failure(let err):
            return .failure(err)
        }
	}

	private func getTextTokenFromStream(stream srcstream: CNStringStream) -> Result<CNToken, NSError> {
		let _ = srcstream.gets(count: 2) // drop first %{
		var prevchar	: Character? = nil
		var haspercent	= false
		let resstr = getAnyStringFromStream(stream: srcstream, matchingFunc: {
			(_ c: Character) -> Bool in
			if prevchar == "%" && c == "}" {
				haspercent = true
				return false
			}
			prevchar = c
			return true
		})
		if haspercent {
			/* Delete last "%" */
			let sidx = resstr.startIndex
			let eidx = resstr.index(before: resstr.endIndex)
			let substr = resstr[sidx..<eidx]

			let _ = srcstream.getc() // drop last %
            return .success(CNToken(type: .TextToken(String(substr)), lineNo: mCurrentLine))
		} else {
			let err = NSError.parseError(message: "Text value is not ended by %} but \"\(resstr)\" is given at \(mCurrentLine)", location: #function)
            return .failure(err)
		}
	}

	private func getCommentFromStream(stream srcstream: CNStringStream) -> CNToken {
		var idx      		= 2	// contains "//"
		var docont   		= true
		while docont {
			if let c = srcstream.peek(offset: idx) {
                if c.isNewline {
					docont   = false // end of comment
				} else {
					idx += 1
				}
			} else {
				docont = false
			}
		}
		/* get skipped characters */
		let comm: String
		if let str = srcstream.gets(count: idx) {
			comm = str
		} else {
			comm = ""
		}
		return CNToken(type: .CommentToken(comm), lineNo: mCurrentLine)
	}

	private func getAnyStringFromStream(stream srcstream: CNStringStream, matchingFunc matchfunc: (_ c:Character) -> Bool) -> String {
		var result: String = ""
		while true {
			if let c = srcstream.getc() {
				if matchfunc(c) {
					result.append(c)
				} else {
					let _ = srcstream.ungetc()
					break
				}
			} else {
				break
			}
		}
		return result
	}

	private func mergeTokens(tokens srcs: Array<CNToken>) -> Array<CNToken> {
		var result: Array<CNToken> = []
		let num = srcs.count
		var i   = 0 ;
		while(i < num) {
			let src = srcs[i]
			var doappend = true
			if let _ = src.getComment() {
				/* Ignore comment and spaces */
				doappend = false
				i += 1
			}
			if doappend {
				result.append(src)
				i += 1
			}
		}
		return result
	}

	private func mergeNumberToken(symbol sym: Character, token src: CNToken) -> CNToken? {
		let isminus = (sym == "-")
		if let val = src.getInt() {
			if isminus {
				return CNToken(type: .IntToken(-val), lineNo: src.lineNo)
			} else {
				return CNToken(type: .IntToken( val), lineNo: src.lineNo)
			}
		} else if let val = src.getUInt() {
			if isminus {
				return CNToken(type: .IntToken(-Int(val)), lineNo: src.lineNo)
			} else {
				return src
			}
		} else if let val = src.getDouble() {
			if isminus {
				return CNToken(type: .DoubleToken(-val), lineNo: src.lineNo)
			} else {
				return CNToken(type: .DoubleToken( val), lineNo: src.lineNo)
			}
		} else {
			return nil
		}
	}
}

