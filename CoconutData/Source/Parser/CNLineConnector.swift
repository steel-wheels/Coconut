/**
 * @file	CNLineConnector.swift
 * @brief	Define CNLineConnector class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

/*
 * if the line has back slash at the end of it, connect it with the next line
 */
public class CNLineConnector
{
	public static func connectLines(lines lns: Array<String>) -> Array<String> {
		var result:	Array<String> = []
		var prevslash:	Bool   = false
		var prevline:	String = ""
		for line in lns {
			let (hasslash, newline) = checkLine(line: line)
			if prevslash {
				prevline = prevline + newline
			} else {
				if !prevline.isEmpty {
					result.append(prevline)
				}
				prevline = newline
			}
			prevslash = hasslash
		}
		if !prevline.isEmpty {
			result.append(prevline)
		}
		return result
	}

	private static func checkLine(line ln: String) -> (Bool, String) {
		if let c = ln.last {
			if c == "\\" {
				return (true, String(ln.dropLast()))
			}
		}
		return (false, ln)
	}
}
