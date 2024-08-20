/**
 * @file	CNValueTypeParser.swift
 * @brief	Define CNValueTypeParser class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNValueTypeParser
{
	public init(){
	}

	public func parse(source src: String) -> Result<Array<CNValueType>, NSError> {
		/* Get tokens from source text*/
        let conf = CNParserConfig(ignoreComments: true, allowIdentiferHasPeriod: false)
		let result: Result<Array<CNValueType>, NSError>
		switch CNStringToToken(string: src, config: conf) {
		case .success(let tokens):
			if tokens.count > 0 {
				/* Parse object */
				switch parseValueTypes(tokenStream: CNTokenStream(source: tokens)) {
				case .success(let vtype):
					result = .success(vtype)
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

	private func parseValueTypes(tokenStream stream: CNTokenStream) -> Result<Array<CNValueType>, NSError> {
		var result: Array<CNValueType> = []
		while !stream.isEmpty() {
			switch parseValueType(tokenStream: stream) {
			case .success(let type):
				result.append(type)
			case .failure(let err):
				return .failure(err)
			}
		}
		return .success(result)
	}

	private func parseValueType(tokenStream stream: CNTokenStream) -> Result<CNValueType, NSError> {
		/* skip "declare" */
		if stream.requireIdentifier(identifier: "declare") {
			/* skip */
		}
		if let ident = stream.requireIdentifier()  {
			return parseValueType(identifier: ident, tokenStream: stream)
		} else if let sym = stream.requireSymbol() {
			return parseValueType(symbol: sym, tokenStream: stream)
		} else {
			let line: String
			if let no = stream.lineNo {
				line = "at line \(no)"
			} else {
				line = ""
			}
			let err = NSError.parseError(message: "Type identifier or \"{\" is required near \(stream.near) \(line)")
			return .failure(err)
		}
	}

	private func parseValueType(identifier ident: String, tokenStream stream: CNTokenStream) -> Result<CNValueType, NSError> {
		let result1: CNValueType
		switch ident {
		case "any":
			result1 = .anyType
		case "boolean":
			result1 = .boolType
		case "number":
			result1 = .numberType
		case "string":
			result1 = .stringType
		case "enum":
			switch parseEnumType(tokenStream: stream) {
			case .success(let type):
				result1 = type
			case .failure(let err):
				return .failure(err)
			}
		case "interface":
			switch parseInterfaceType(tokenStream: stream) {
			case .success(let type):
				result1 = type
			case .failure(let err):
				return .failure(err)
			}
		case "void":
			result1 = .voidType
		default:
			switch identifierToType(identifier: ident) {
			case .success(let vtype):
				result1 = vtype
			case .failure(let err):
				return .failure(err)
			}
		}

		let result2: CNValueType
		switch parseValueTypePostfix(tokenStream: stream, baseType: result1) {
		case .success(let vtype):
			result2 = vtype
		case .failure(let err):
			return .failure(err)
		}

		return .success(result2)
	}

	private func parseValueType(symbol sym: Character, tokenStream stream: CNTokenStream) -> Result<CNValueType, NSError> {
		switch sym {
		case "{":
			/*
			 * example: {[name: string]: SpriteNodeDeclIF}
			 */
			guard stream.requireSymbol(symbol: "[") else {
				let line: String = "\(String(describing: stream.lineNo))"
				let err = NSError.parseError(message: "Symbol \"[\" is required near \(stream.near) \(line)")
				return .failure(err)
			}
			guard let _ = stream.requireIdentifier() else {
				let line: String = "\(String(describing: stream.lineNo))"
				let err = NSError.parseError(message: "Any identifier is required near \(stream.near) \(line)")
				return .failure(err)
			}
			guard stream.requireSymbol(symbol: ":") else {
				let line: String = "\(String(describing: stream.lineNo))"
				let err = NSError.parseError(message: "Symbol \":\" is required near \(stream.near) \(line)")
				return .failure(err)
			}
			switch parseValueType(tokenStream: stream){
			case .success(let etype):
				switch etype {
				case .stringType:
					break	// go next
				default:
					let line: String = "\(String(describing: stream.lineNo))"
					let err = NSError.parseError(message: "The key of dictionary must be string near \(stream.near) \(line)")
					return .failure(err)
				}
			case .failure(let err):
				return .failure(err)
			}
			guard stream.requireSymbol(symbol: "]") else {
				let line: String = "\(String(describing: stream.lineNo))"
				let err = NSError.parseError(message: "Symbol \"]\" is required near \(stream.near) \(line)")
				return .failure(err)
			}
			guard stream.requireSymbol(symbol: ":") else {
				let line: String = "\(String(describing: stream.lineNo))"
				let err = NSError.parseError(message: "Symbol \":\" is required near \(stream.near) \(line)")
				return .failure(err)
			}
			let dicttype: CNValueType
			switch parseValueType(tokenStream: stream) {
			case .success(let typ):
				dicttype = typ
			case .failure(let err):
				return .failure(err)
			}
			guard stream.requireSymbol(symbol: "}") else {
				let line: String = "\(String(describing: stream.lineNo))"
				let err = NSError.parseError(message: "Symbol \"]\" is required near \(stream.near) \(line)")
				return .failure(err)
			}
			return .success(.dictionaryType(dicttype))
		default:
			let line: String = "\(String(describing: stream.lineNo))"
			let err = NSError.parseError(message: "Unexpected symbol \"\(sym)\" near \(stream.near) \(line)")
			return .failure(err)
		}
	}

	/* decode postfix: "[]" or "| null" */
	private func parseValueTypePostfix(tokenStream stream: CNTokenStream, baseType btype: CNValueType) -> Result<CNValueType, NSError> {
		var result: CNValueType = btype
		var docont = true
		while docont {
			if stream.requireSymbol(symbol: "|") {
				if stream.requireIdentifier(identifier: "null") {
					result = .nullable(result)
					docont = false // can not continue
				} else {
                    let err = NSError.parseError(message: "Multi type is not allowed (except null) at line \(stream.code(withComment: true))")
					return .failure(err)
				}
			} else if stream.requireSymbol(symbol: "[") {
				if stream.requireSymbol(symbol: "]") {
					result = .arrayType(result)
				} else {
					let err = NSError.parseError(message: "\"]\" is required but not given at line \(stream.code(withComment: true))")
					return .failure(err)
				}
			} else {
				docont = false
			}
		}
		return .success(result)
	}

	private func identifierToType(identifier ident: String) -> Result<CNValueType, NSError> {
		let vmgr = CNValueTypeManager.shared
		if let itype = vmgr.searchInterfaceType(byTypeName: ident) {
			return .success(.interfaceType(itype))
		} else if let etype = vmgr.searchEnumType(byTypeName: ident) {
			return .success(.enumType(etype))
		} else {
			let err = NSError.parseError(message: "Unknown type name: \(ident)")
			return .failure(err)
		}
	}

	private func parseEnumType(tokenStream stream: CNTokenStream) -> Result<CNValueType, NSError> {
		/* <enum> week {
		 * 	sunday  = 0 ;
		 *	monday  = 1 ;
		 *	tuesday = 2 ;
		 * }
		 */
		guard let typename = stream.requireIdentifier() else {
			let err = NSError.parseError(message: "Enum name is expected at \(stream.near)")
			return .failure(err)
		}
		guard stream.requireSymbol(symbol: "{") else {
			let err = NSError.parseError(message: "\"{\" to declare enum members is required at \(stream.near)")
			return .failure(err)
		}
		let newtype = CNEnumType(typeName: typename)
		var is1st   = true
		while !stream.requireSymbol(symbol: "}") {
			switch parseEnumMember(tokenStream: stream, is1stMembet: is1st) {
			case .success((let name, let val)):
				newtype.add(name: name, value: val)
			case .failure(let err):
				return .failure(err)
			}
			is1st = false
		}
		let vmgr = CNValueTypeManager.shared
		vmgr.add(enumType: newtype)
		return .success(.enumType(newtype))
	}

	private func parseEnumMember(tokenStream stream: CNTokenStream, is1stMembet is1st: Bool) -> Result<(String, CNEnumType.Value), NSError> {
		if !is1st {
			if !stream.requireSymbol(symbol: ",") {
				let err = NSError.parseError(message: "\",\" is required between enum member definition at \(stream.near)")
				return .failure(err)
			}
		}

		guard let membname = stream.requireIdentifier() else {
			let err = NSError.parseError(message: "enum member name is required at \(stream.near)")
			return .failure(err)
		}
		guard stream.requireSymbol(symbol: "=") else {
			let err = NSError.parseError(message: "\"=\" is required between enum name and value at \(stream.near)")
			return .failure(err)
		}
		let membval: CNEnumType.Value
		if let ival = stream.requireUInt() {
			membval = .intValue(Int(ival))
		} else if let sval = stream.requireString() {
			membval = .stringValue(sval)
		} else {
			let err = NSError.parseError(message: "enum value is required at \(stream.near)")
			return .failure(err)
		}
		return .success((membname, membval))
	}

	private func parseInterfaceType(tokenStream stream: CNTokenStream) -> Result<CNValueType, NSError> {
		/* <interface> dog: animal {
		 *	run(): void ;
		 * }
		 */
		guard let ifname = stream.requireIdentifier() else {
			let err = NSError.parseError(message: "interface name is required at \(stream.near)")
			return .failure(err)
		}
		let vmgr = CNValueTypeManager.shared
		let baseif: CNInterfaceType?
		if stream.requireIdentifier(identifier: "extends") {
			if let bname = stream.requireIdentifier() {
				if let bif = vmgr.searchInterfaceType(byTypeName: bname) {
					baseif = bif
				} else {
					let err = NSError.parseError(message: "The base interface is not found: \(bname) at \(stream.near)")
					return .failure(err)
				}
			} else {
				let err = NSError.parseError(message: "Super class of the interface is required at \(stream.near)")
				return .failure(err)
			}
		} else {
			baseif = nil
		}
		guard stream.requireSymbol(symbol: "{") else {
			let err = NSError.parseError(message: "\"{\" to declare interface members is required at \(stream.near)")
			return .failure(err)
		}

		/* Allocate interface before parsing members.
		 * Because the member will refer the self type.
		 */
		let newtype = CNInterfaceType(name: ifname, base: baseif, members: [])
		vmgr.add(interfaceType: newtype)

		var members: Array<CNInterfaceType.Member> = []
		while !stream.requireSymbol(symbol: "}") {
			switch parseInterfaceMember(tokenStream: stream) {
			case .success(let membp):
				if let memb = membp {
					members.append(memb)
				}
			case .failure(let err):
				return .failure(err)
			}
		}

		/* Add parsed members */
		newtype.add(members: members)
		return .success(.interfaceType(newtype))
	}

	private func parseInterfaceMember(tokenStream stream: CNTokenStream) -> Result<CNInterfaceType.Member?, NSError> {
		guard let pname = stream.requireIdentifier() else {
			let err = NSError.parseError(message: "property name of interface is required at \(stream.near)")
			return .failure(err)
		}
		// Parse function parameters if it exist
		var isfunc: Bool = false
		var paramtypes: Array<CNValueType> = []
		if stream.requireSymbol(symbol: "(") {
			var is1stparam = true
			while !stream.requireSymbol(symbol: ")") {
				if is1stparam {
					is1stparam = false
				} else {
					if !stream.requireSymbol(symbol: ",") {
						let err = NSError.parseError(message: "\",\" is required between parameter and type at \(stream.near)")
						return .failure(err)
					}
				}
				switch parseParameterType(tokenStream: stream) {
				case .success(let ptype):
					paramtypes.append(ptype)
				case .failure(let err):
					return .failure(err)
				}
			}
			isfunc = true
		}
		guard stream.requireSymbol(symbol: ":") else {
			let err = NSError.parseError(message: "\":\" is required after property name at \(stream.near)")
			return .failure(err)
		}
		switch parseValueType(tokenStream: stream) {
		case .success(let rettype):
			let memb: CNInterfaceType.Member
			if isfunc {
				let functype: CNValueType = .functionType(rettype, paramtypes)
				memb = CNInterfaceType.Member(name: pname, type: functype)
			} else {
				memb = CNInterfaceType.Member(name: pname, type: rettype)
			}
			if stream.requireSymbol(symbol: ";") {
				/* skip */
			}
			return .success(memb)
		case .failure(let err):
			return .failure(err)
		}
	}

	private func parseParameterType(tokenStream stream: CNTokenStream) -> Result<CNValueType, NSError> {
		guard let _ = stream.requireIdentifier() else {
			let err = NSError.parseError(message: "parameter name of function is required at \(stream.near)")
			return .failure(err)
		}
		guard stream.requireSymbol(symbol: ":") else {
			let err = NSError.parseError(message: "\":\" is required between property name and type at \(stream.near)")
			return .failure(err)
		}
		switch parseValueType(tokenStream: stream){
		case .success(let type):
			return .success(type)
		case .failure(let err):
			return .failure(err)
		}
	}
}

