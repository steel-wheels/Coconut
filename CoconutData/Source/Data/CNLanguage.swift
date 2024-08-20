/**
 * @file	CNLanguage.swift
 * @brief	Define CNLanguage class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public enum CNLanguage: Int
{
	case chinese
	case deutsch
	case english
	case french
	case italian
	case japanese
	case korean
	case russian
	case spanish
	case others

	public static func allocateEnumType() -> CNEnumType {
		let etype = CNEnumType(typeName: "Language")
		etype.add(members: [
			"chinese":	.intValue(CNLanguage.chinese.rawValue),
			"deutch":	.intValue(CNLanguage.deutsch.rawValue),
			"english":	.intValue(CNLanguage.english.rawValue),
			"french":	.intValue(CNLanguage.french.rawValue),
			"italian":	.intValue(CNLanguage.italian.rawValue),
			"japanese":	.intValue(CNLanguage.japanese.rawValue),
			"korean":	.intValue(CNLanguage.korean.rawValue),
			"russian":	.intValue(CNLanguage.russian.rawValue),
			"spanish":	.intValue(CNLanguage.spanish.rawValue),
			"others":	.intValue(CNLanguage.others.rawValue)
		])
		return etype
	}

	public var enumValue: CNEnum { get {
		let etype = CNLanguage.allocateEnumType()
		let eval  = self.description
		return CNEnum(type: etype, member: eval)
	}}

	public var description: String { get {
		let result: String
		switch self {
		case .chinese:		result = "chinese"
		case .deutsch:		result = "deutch"
		case .english:		result = "english"
		case .french:		result = "french"
		case .italian:		result = "italian"
		case .japanese:		result = "japanese"
		case .korean:		result = "korean"
		case .russian:		result = "russian"
		case .spanish:		result = "spanish"
		case .others:		result = "others"
		}
		return result
	}}

	/*
	 * this code used at google search query
	 */
	public var code: String { get {
		let result: String
		switch self {
		case .chinese:		result = "zh-CN"
		case .deutsch:		result = "de"
		case .english:		result = "en"
		case .french:		result = "fr"
		case .italian:		result = "it"
		case .japanese:		result = "ja"
		case .korean:		result = "ko"
		case .russian:		result = "ru"
		case .spanish:		result = "es"
		case .others:		result = "others"
		}
		return result
	}}
}
