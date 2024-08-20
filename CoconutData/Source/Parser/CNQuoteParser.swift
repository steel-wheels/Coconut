/**
 * @file	CNQuoteParser.swift
 * @brief	Define CNQuoteParser class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

/*
 * Extract quoted string in the text line
 */
public class CNQuoteParser
{
	public enum QString{
		case normal(String)
		case quoted(String)
	}

	private var result: 		Array<QString>
	private var currentString:	String
	private var previousQuote:	Character?

	public init(){
		result		= []
		currentString	= ""
		previousQuote	= nil
	}

	public func clear() {
		result		= []
		currentString	= ""
		previousQuote	= nil
	}

	public func parse(source src: String) -> Result<Array<QString>, NSError>
	{
		var idx		= src.startIndex
		let end		= src.endIndex
		var didescaped	= false

		clear()

		while idx < end {
			let c = src[idx]
			didescaped = parse(char: c, didEscaped: didescaped)
			idx = src.index(after: idx)
		}
		if let quote = previousQuote {
			let err = NSError.parseError(message: "Not closed quote: \(quote)")
			return .failure(err)
		} else {
			flushCurrentLine(isQuoted: false)
			return .success(result)
		}
	}

	private func parse(char c: Character, didEscaped didesc: Bool) -> Bool
	{
		var result = false
		if isQuote(c) {
			if didesc {
				if let pquoto = previousQuote {
					if pquoto != c {
						updateCurrentLine(char: "\\")
					}
				} else {
					updateCurrentLine(char: "\\")
				}
				/* treat quote as a string */
				updateCurrentLine(char: c)
			} else {
				if let pquoto = previousQuote {
					if pquoto == c {
						/* this is end of quote */
						flushCurrentLine(isQuoted: true)
						previousQuote = nil
					} else {
						/* this not expected quote */
						updateCurrentLine(char: c)
					}
				} else {
					/* this is start of quote */
					flushCurrentLine(isQuoted: false)
					previousQuote = c
				}
			}
		} else if c == "\\" {
			result = true
		} else {
			if didesc {
				updateCurrentLine(char: "\\")
			}
			updateCurrentLine(char: c)
		}
		return result
	}

	private func updateCurrentLine(char c: Character){
		currentString += String(c)
	}

	private func flushCurrentLine(isQuoted isq: Bool) {
		if !currentString.isEmpty {
			let qstr: QString = isq ? .quoted(currentString) : .normal(currentString)
			result.append(qstr)
		}
		currentString = ""
	}

	private func isQuote(_ c: Character) -> Bool {
		return (c == "'") || (c == "\"")
	}
}
