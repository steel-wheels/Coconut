/**
 * @file	UTQuoteParser.swift
 * @brief	Test function for CNQuoteParser class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import CoconutData
import Foundation

public func testParser(console cons: CNConsole) -> Bool
{
	let res0 = testQuoteParser(console: cons)
	let res1 = testLineConnector(console: cons)
	let res2 = testCommandParser(console: cons)
	return res0 && res1 && res2
}

private func testQuoteParser(console cons: CNConsole) -> Bool
{
	let res0 = quoteParser(source: "a", console: cons)
	let res1 = quoteParser(source: " a b c ", console: cons)
	let res2 = quoteParser(source: " a \"b\" c ", console: cons)
	let res3 = quoteParser(source: "\"a b 'c\"", console: cons)
	let res4 = quoteParser(source: "a \\\"b c", console: cons)
	let res5 = quoteParser(source: "a \"\\\"b c\"", console: cons)
	let res6 = quoteParser(source: "a -b | c", console: cons)
	return res0 && res1 && res2 && res3 && res4 && res5 && res6
}

private func quoteParser(source src: String, console cons: CNConsole) -> Bool
{
	let result: Bool
	cons.print(string: "testQuoteParser: \(src) -> ")
	let parser = CNQuoteParser()
	switch parser.parse(source: src) {
	case .success(let qstrs):
		for qstr in qstrs {
			switch qstr {
			case .normal(let nstr):
				cons.print(string: "normal(\(nstr)) ")
			case .quoted(let nstr):
				cons.print(string: "quoted(\(nstr)) ")
			}
		}
		cons.print(string: "\n")
		result = true
	case .failure(let err):
		cons.print(string: "[Error] " + err.toString() + "\n")
		result = false
	}
	return result
}

private func testLineConnector(console cons: CNConsole) -> Bool
{
	let lines0: Array<String> = [
		"a"
	]
	let res0 = lineConnect(lines: lines0, lineCount: 1, console: cons)

	let lines1: Array<String> = [
		"a", "b"
	]
	let res1 = lineConnect(lines: lines1, lineCount: 2, console: cons)

	let lines2: Array<String> = [
		"a", "b\\", "c"
	]
	let res2 = lineConnect(lines: lines2, lineCount: 2, console: cons)

	return res0 && res1 && res2
}

private func lineConnect(lines src: Array<String>, lineCount lc: Int, console cons: CNConsole) -> Bool {
	cons.print(string: "connect lines: ")
	for s in src {
		cons.print(string: "src: \(s)\n")
	}

	let result = CNLineConnector.connectLines(lines: src)
	for r in result {
		cons.print(string: "result: \(r)\n")
	}
	if result.count == lc {
		cons.print(string: "-> expected line num\n")
		return true
	} else {
		cons.print(string: "-> unexpected line num (Error)\n")
		return false
	}
}

private func testCommandParser(console cons: CNConsole) -> Bool
{
	var result = true

	let lines0 = [ "a" ]
	result = commandParser(lines: lines0, console: cons) && result

	let lines1 = [ "a -b" ]
	result = commandParser(lines: lines1, console: cons) && result

	let lines2 = [ "a -b | c -d ", "e" ]
	result = commandParser(lines: lines2, console: cons) && result

	let lines3 = [ " a == b || c == d | cat", "e", "f" ]
	result = commandParser(lines: lines3, console: cons) && result

	return result
}

private func commandParser(lines lns: Array<String>, console cons: CNConsole) -> Bool
{
	let result: Bool

	cons.print(string: "Source: \(lns)\n")

	let parser = CNCommandLineParser()
	switch parser.parse(lines: lns) {
	case .success(let cmdln):
		let strs = cmdln.toText().toStrings()
		for str in strs {
			cons.print(string: str + "\n")
		}
		result = true
	case .failure(let err):
		cons.error(string: "[Error] " + err.toString())
		result = false
	}
	return result
}

