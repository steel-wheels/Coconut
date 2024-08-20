/**
 * @file	CNValueFormatter.swift
 * @brief	Define CNValueFormatter class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Foundation

public class CNValueFormatter
{
	private var mPath: CNStack<String>

	public init(){
		mPath = CNStack<String>()
	}

	private func pushPath(_ pth: String) {
		mPath.push(pth)
	}

	private func popPath() {
		let _ = mPath.pop()
	}

	private func near(fileName fname: String?) -> String {
		var result: String = ""
		if mPath.count > 0 {
			result += " near " + mPath.peekAll(doReverseOrder: false).joined(separator: ".")
		}
		return result
	}

	public func load(source src: CNValue, type typ: CNValueType, from fname: String?) -> Result<CNValue, NSError> {
		switch typ {
		case .anyType:
			return .success(src)
		case .boolType:
			if let _ = src.toBool() {
				return .success(src)
			} else {
				let err = NSError.parseError(message: "Boolean value is expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .numberType:
			if let _ = src.toNumber() {
				return .success(src)
			} else {
				let err = NSError.parseError(message: "Number value is expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .stringType:
			if let _ = src.toString() {
				return .success(src)
			} else {
				let err = NSError.parseError(message: "String value is expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .arrayType(let etype):
			if let elms = src.toArray() {
				var result: Array<CNValue> = []
				for elm in elms {
					switch load(source: elm, type: etype, from: fname) {
					case .success(let retval):
						result.append(retval)
					case .failure(let err):
						return .failure(err)
					}
				}
				return .success(.arrayValue(result))
			} else {
				let err = NSError.parseError(message: "Array of values are expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .setType(let etype):
			if let elms = src.toSet() {
				var result: Array<CNValue> = []
				for elm in elms {
					switch load(source: elm, type: etype, from: fname) {
					case .success(let retval):
						result.append(retval)
					case .failure(let err):
						return .failure(err)
					}
				}
				return .success(.arrayValue(result))
			} else {
				let err = NSError.parseError(message: "Set of values are expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .dictionaryType(let elmtype):
			if let dict = src.toDictionary() {
				var result: Dictionary<String, CNValue> = [:]
				for (ename, eval) in dict {
					pushPath(ename)
					switch load(source: eval, type: elmtype, from: fname) {
					case .success(let retval):
						result[ename] = retval
					case .failure(let err):
						return .failure(err)
					}
					popPath()
				}
				return .success(.dictionaryValue(result))
			} else {
				let err = NSError.parseError(message: "Dictionary of values are expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .nullable(let elmtype):
			return load(source: src, type: elmtype, from: fname)
		case .enumType(let etype):
			if let eval = src.toEnum() {
				if eval.typeName == etype.typeName {
					return .success(src)
				} else {
					let err = NSError.parseError(message: "Enum type mismatch\(near(fileName: fname))")
					return .failure(err)
				}
			} else if let num = src.toNumber() {
				if let eval = etype.search(byValue: .intValue(num.intValue)) {
					return .success(.enumValue(eval))
				} else {
					let err = NSError.parseError(message: "Non exist enum member value\(near(fileName: fname))")
					return .failure(err)
				}
			} else if let str = src.toString() {
				if let eval = etype.search(byValue: .stringValue(str)) {
					return .success(.enumValue(eval))
				} else {
					let err = NSError.parseError(message: "Non exist enum member value\(near(fileName: fname))")
					return .failure(err)
				}
			} else {
				let err = NSError.parseError(message: "Not enum member value \(src.description)\(near(fileName: fname))")
				return .failure(err)
			}
		case .interfaceType(let iftype):
			if let ifval = src.toInterface(interfaceName: iftype.name) {
				return .success(.interfaceValue(ifval))
			} else if let dict = src.toDictionary() {
				if iftype.members.count == dict.keys.count {
					let result = CNInterfaceValue(types: iftype, values: [:])
					for memb in iftype.members {
						pushPath(memb.name)
						if let val = dict[memb.name] {
							switch load(source: val, type: memb.type, from: fname) {
							case .success(let retval):
								result.set(name: memb.name, value: retval)
							case .failure(let err):
								return .failure(err)
							}
						} else {
							let err = NSError.parseError(message: "Interface member \"\(memb.name)\" is required\(near(fileName: fname))")
							return .failure(err)
						}
						popPath()
					}
					return .success(.interfaceValue(result))
				} else {
					let err = NSError.parseError(message: "Unmatched interface member count\(near(fileName: fname))")
					return .failure(err)
				}
			} else {
				let err = NSError.parseError(message: "Interface values is expected\(near(fileName: fname))")
				return .failure(err)
			}
		case .objectType(_):
			let err = NSError.parseError(message: "Object type is not supported by JSON data")
			return .failure(err)
		case .voidType:
			let err = NSError.parseError(message: "Void type is not supported by JSON data")
			return .failure(err)
		case .functionType(_, _):
			let err = NSError.parseError(message: "Function type is not supported by JSON data")
			return .failure(err)
		}
	}
}

