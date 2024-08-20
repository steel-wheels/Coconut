/**
 * @file	CNValueTypeGenerator.swift
 * @brief	Define CNValueTypeGenerator class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNValueTypeGenerator
{
	public init(){
	}

	public func generateValueType(valueType vtype: CNValueType, isInside inside: Bool) -> Array<String> {
		var result: Array<String> = []
		switch vtype {
		case .voidType:			result.append("void")
		case .anyType:			result.append("any")
		case .boolType:			result.append("boolean")
		case .numberType:		result.append("number")
		case .stringType:		result.append("string")
		case .enumType(let etype):
			result.append(contentsOf: generateEnumType(enumType: etype, isInside: inside))
		case .dictionaryType(let elmtype):
			let elmstr = generateValueType(valueType: elmtype, isInside: inside).joined(separator: " ")
			let line   = "{ [name: string]: \(elmstr) }"
			result.append(line)
		case .arrayType(let elmtype):
			let elmstr = generateValueType(valueType: elmtype, isInside: inside).joined(separator: " ")
			let line   = elmstr + "[]"
			result.append(line)
		case .setType(let elmtype):
			let elmstr = generateValueType(valueType: elmtype, isInside: inside).joined(separator: " ")
			let line   = elmstr + "[]"
			result.append(line)
		case .interfaceType(let iftype):
			let lines = generateInterfaceType(interfaceType: iftype, isInside: inside)
			result.append(contentsOf: lines)
		case .functionType(let rettype, let paramtypes):
			let line = generateFunctionType(name: "", returnType: rettype, parameterTypes: paramtypes)
			result.append(line)
		case .objectType(let classname):
			if let name = classname {
				result.append(name)
			} else {
				CNLog(logLevel: .error, message: "Failed to generate object type")
				result.append("any")
			}
		case .nullable(let elmtype):
			let elmstr = generateValueType(valueType: elmtype, isInside: inside).joined(separator: " ")
			let line   = elmstr + "| null"
			result.append(line)

		}
		return result
	}

	public func generateEnumType(enumType vtype: CNEnumType, isInside inside: Bool) -> Array<String> {
		var result: Array<String>
		if inside {
			result = [ vtype.typeName ]
		} else {
			var lines: Array<String> = ["enum \(vtype.typeName) {"]
			let names = vtype.names
			let count = names.count
			for i in 0..<count {
				let name   = names[i]
				let islast = (i == count - 1)
				if let val = vtype.value(forMember: name) {
					let valstr: String
					switch val {
					case .intValue(let imm): 	valstr = "\(imm)"
					case .stringValue(let imm):	valstr = "\"\(imm)\""
					}
					let divider: String = islast ? "" : ","
					let line = "  \(name) = \(valstr)\(divider)"
					lines.append(line)
				}
			}
			lines.append("}")
			result = lines
		}
		return result
	}

	public func generateInterfaceType(interfaceType vtype: CNInterfaceType, isInside inside: Bool) -> Array<String> {
		let result: Array<String>
		if inside {
			result = [ vtype.name ]
		} else {
			let basedecl: String
			if let bif = vtype.base {
				basedecl = "extends \(bif.name)"
			} else {
				basedecl = ""
			}
			var lines: Array<String> = ["interface \(vtype.name) \(basedecl) {"]
			for memb in vtype.members {
				switch memb.type {
				case .functionType(let rettype, let paramtypes):
					let line = generateFunctionType(name: memb.name, returnType: rettype, parameterTypes: paramtypes)
					lines.append(line + " ;")
				default:
					let tlines = generateValueType(valueType: memb.type, isInside: true)
					let tdecl  = tlines.joined(separator: " ")
					let line   = "  \(memb.name) : \(tdecl) ;"
					lines.append(line)
				}
			}
			lines.append("}")
			result = lines
		}
		return result
	}

	public func generateFunctionType(name nm: String, returnType rettype: CNValueType, parameterTypes ptypes: Array<CNValueType>) -> String {
		var paramstr = "("
		var is1st    = true
		for i in 0..<ptypes.count {
			if is1st {
				is1st = false
			} else {
				paramstr += ", "
			}
			let ptypestr = generateValueType(valueType: ptypes[i], isInside: true).joined(separator: " ")
			paramstr += "p\(i): " + ptypestr
		}
		paramstr += ")"
		let retstr = generateValueType(valueType: rettype, isInside: true).joined(separator: " ")
		return nm + paramstr + ": " + retstr
	}
}

