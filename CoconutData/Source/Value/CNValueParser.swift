/**
 * @file	CNValueParser.swift
 * @brief	Define CNValueParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public class CNValueParser
{
	public struct Property {
		public var 	name	: String
		public var 	value	: CNValue
		public init(name nm: String, value val: CNValue){
			name 	= nm
			value	= val
		}
	}

	public init(){
	}

	public func parse(source src: String) -> Result<CNValue, NSError> {
		/* Get tokens from source text*/
        let conf = CNParserConfig(ignoreComments: true, allowIdentiferHasPeriod: false)
		let result: Result<CNValue, NSError>
		switch CNStringToToken(string: src, config: conf) {
		case .success(let tokens):
			if tokens.count > 0 {
				/* Parse object */
				switch parseValue(tokenStream: CNTokenStream(source: tokens)) {
				case .success(let val):
					let dec = decodeDictionary(value: val)
					result = .success(dec)
				case .failure(let err):
					result = .failure(err)
				}
			} else {
				result = .failure(NSError.parseError(message: "No contents"))
			}
		case .failure(let err):
			result = .failure(err)
		}
		return result
	}

	private func decodeDictionary(value src: CNValue) -> CNValue {
		let dst: CNValue
		switch src {
		case .boolValue(_), .numberValue(_), .stringValue(_), .setValue(_),
		     .enumValue(_), .objectValue(_), .interfaceValue(_):
			dst = src
		case .dictionaryValue(let dict):
			if let obj = CNDictionaryToValue(dictionary: dict) {
				dst = obj
			} else {
				var newdict: Dictionary<String, CNValue> = [:]
				for (key, val) in dict {
					newdict[key] = decodeDictionary(value: val)
				}
				dst = .dictionaryValue(newdict)
			}
		case .arrayValue(let arr):
			var newarr: Array<CNValue> = []
			for elm in arr {
				let newelm = decodeDictionary(value: elm)
				newarr.append(newelm)
			}
			dst = .arrayValue(newarr)
		}
		return dst
	}

	private func parseValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		if let c = stream.requireSymbol() {
			switch c {
			case "{":
				let _ = stream.unget()
				return parseObjectValue(tokenStream: stream)
			case "[":
				let _ = stream.unget()
				return parseArrayValue(tokenStream: stream)
			case ".":
				if let ident = stream.requireIdentifier() {
					switch parseEnumValue(typeName: nil, memberName: ident, tokenStream: stream){
					case .success(let val):
						return .success(val)
					case .failure(let err):
						return .failure(err)
					}
				} else {
					return .failure(NSError.parseError(message: "Enum member identifier is required after \".\" \(near(stream))"))
				}
			default:
				return .failure(NSError.parseError(message: "Unexpected symbol \"\(c)\" \(near(stream))"))
			}
		} else {
			return parseScalarValue(tokenStream: stream)
		}
	}

	private func parseObjectValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard stream.requireSymbol() == "{" else {
			return .failure(NSError.parseError(message: "Symbol \"{\" is required \(near(stream))"))
		}
		var result: Dictionary<String, CNValue> = [:]
		var is1st = true
		parse_loop: while true {
			if stream.requireSymbol(symbol: "}") {
				break parse_loop
			}
			if !is1st {
				/* ignore comma (option) */
				let _ = stream.requireSymbol(symbol: ",")
			}
			switch parseProperty(tokenStream: stream) {
			case .success(let prop):
				result[prop.name] = prop.value
			case .failure(let err):
				return .failure(err)
			}
			is1st = false
		}
		return .success(.dictionaryValue(result))
	}

	private func parseArrayValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard stream.requireSymbol() == "[" else {
			return .failure(NSError.parseError(message: "Symbol \"{\" is required \(near(stream))"))
		}
		var result: Array<CNValue> = []
		var is1st = true
		parse_loop: while true {
			if stream.requireSymbol(symbol: "]") {
				break parse_loop
			}
			if !is1st {
				/* Ignore comma (option) */
				let _ = stream.requireSymbol(symbol: ",")
			}
			switch parseValue(tokenStream: stream) {
			case .success(let elm):
				result.append(elm)
			case .failure(let err):
				return .failure(err)
			}
			is1st = false
		}
		return .success(.arrayValue(result))
	}

	private func parseProperty(tokenStream stream: CNTokenStream) -> Result<Property, NSError> {
		guard let ident = stream.requireIdentifier() else {
			return .failure(NSError.parseError(message: "Identifier for property name is required \(near(stream))"))
		}
		guard stream.requireSymbol(symbol: ":") else {
			return .failure(NSError.parseError(message: "Symbol \":\" is required between property name and value\(near(stream))"))
		}
		switch parseValue(tokenStream: stream) {
		case .success(let val):
			return .success(Property(name: ident, value: val))
		case .failure(let err):
			return .failure(err)
		}
	}

	private func parseScalarValue(tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard let token = stream.get() else {
			return .failure(NSError.parseError(message: "Unexpected end of stream \(near(stream))"))
		}
		let result: CNValue
		switch token.type {
		case .BoolToken(let value):	result = .numberValue(NSNumber(value: value))
		case .IntToken(let value):	result = .numberValue(NSNumber(value: value))
		case .UIntToken(let value):	result = .numberValue(NSNumber(value: value))
		case .DoubleToken(let value):	result = .numberValue(NSNumber(value: value))
		case .StringToken(let value):	result = .stringValue(value)
		case .TextToken(let value):	result = .stringValue(value)
		case .ReservedWordToken(let rid):
			return .failure(NSError.parseError(message: "Reserved word is not supported: \(rid) \(near(stream))"))
		case .SymbolToken(_):
			return .failure(NSError.parseError(message: "Can not happen (0) \(near(stream))"))
		case .IdentifierToken(let str):
			switch str.lowercased() {
			case "null":
				result = CNValue.null
			default:
				switch parseEnumValue(typeName: str, tokenStream: stream) {
				case .success(let val):
					result = val
				case .failure(let err):
					return .failure(err)
				}
			}
		case .CommentToken(_):
			return .failure(NSError.parseError(message: "Can not happen \(near(stream))"))
		}
		return .success(result)
	}

	public func parseEnumValue(typeName tname: String, tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		guard stream.requireSymbol(symbol: ".") else {
			return .failure(NSError.parseError(message: "\".\" is required before enum value \(near(stream))"))
		}
		guard let mname = stream.getIdentifier() else {
			return .failure(NSError.parseError(message: "Enum member name is required after \".\" \(near(stream))"))
		}
		return parseEnumValue(typeName: tname, memberName: mname, tokenStream: stream)
	}

	public func parseEnumValue(typeName tnamep: String?, memberName mname: String, tokenStream stream: CNTokenStream) -> Result<CNValue, NSError> {
		let vmgr = CNValueTypeManager.shared
		if let tname = tnamep {
			if let etype = vmgr.searchEnumType(byTypeName: tname) {
				if let eobj = etype.allocate(name: mname) {
					return .success(.enumValue(eobj))
				} else {
					return .failure(NSError.parseError(message: "Enum type \(tname) does not have member \(mname)"))
				}
			} else {
				return .failure(NSError.parseError(message: "Enum type \(tname) is not exist"))
			}
		} else {
			let eobjs = vmgr.searchEnums(byMemberName: mname)
			switch eobjs.count {
			case 0:
				return .failure(NSError.parseError(message: "Enum member .\(mname) is not found \(near(stream))"))
			case 1:
				return .success(.enumValue(eobjs[0]))
			default: // 2 or more
				CNLog(logLevel: .error, message: "Enum member .\(mname) is used by multiple enum types \(near(stream))")
				return .success(.enumValue(eobjs[0]))
			}
		}
	}

	private func near(_ strm: CNTokenStream) -> String {
		var result = ""
		if let token = strm.peek(offset: 0) {
			result += ": near \"" + token.code(withComment: true) + "\""
		}
		if let no = strm.lineNo {
			result += " at line \(no)"
		}
		return result
	}
}

