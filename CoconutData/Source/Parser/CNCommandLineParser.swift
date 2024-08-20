/**
 * @file	CNCommandLineParser.swift
 * @brief	Define CNCommaneLineParser class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNCommandLineParser
{
	public typealias QString = CNQuoteParser.QString

	public struct CommandLine {
		public var pipes:	Array<CommandPipe>

		public init(pipes pp: Array<CommandPipe>) {
			self.pipes = pp
		}

		public func allCommandNames() -> Array<String> {
			var result: Array<String> = []
			for pipe in pipes {
				let names = pipe.allCommandNames()
				result.append(contentsOf: names)
			}
			return result
		}

		public func toText() -> CNTextSection {
			let sect = CNTextSection()
			sect.header = "commandLine: {"
			sect.footer = "}"
			for pipe in pipes {
				sect.add(text: pipe.toText())
			}
			return sect
		}
	}

	public struct CommandPipe {
		public var commands:	Array<Command>

		public init(commands cmds: Array<Command>) {
			self.commands = cmds
		}

		public func allCommandNames() -> Array<String> {
			var result: Array<String> = []
			for cmd in commands {
				result.append(cmd.commandName)
			}
			return result
		}

		public func toText() -> CNTextSection {
			let sect = CNTextSection()
			sect.header = "pipe: {"
			sect.footer = "}"
			for command in commands {
				sect.add(text: command.toText())
			}
			return sect
		}
	}

	public struct Command {
		public var uniqueId:	Int
		public var commandName:	String
		public var arguments:	Array<String>

		public init(uniqueId uid: Int, commandName cmdname: String, arguments args: Array<String>) {
			self.uniqueId    = uid
			self.commandName = cmdname
			self.arguments   = args
		}

		public func toText() -> CNTextSection {
			let sect = CNTextSection()
			sect.header = "command: {"
			sect.footer = "}"
			sect.add(text: CNTextLine(string: "commandName: \(commandName)"))
			for arg in arguments {
				sect.add(text: CNTextLine(string: "argument: \(arg)"))
			}
			return sect
		}
	}

	public init() {

	}

	public func parse(lines lns: Array<String>) -> Result<CommandLine, NSError>
	{
		var result: Array<CommandPipe> = []
		let mlines  = CNLineConnector.connectLines(lines: lns)
		//NSLog("connectLines: \(mlines)")

		var uid: Int = 0
		let qparser = CNQuoteParser()
		for line in mlines {
			switch qparser.parse(source: line) {
			case .success(let qstrs):
				switch parseQStrings(qstrings: qstrs, uniqueId: &uid) {
				case .success(let pipe):
					result.append(pipe)
				case .failure(let err):
					return .failure(err)
				}
			case .failure(let err):
				return .failure(err)
			}
		}
		return .success(CommandLine(pipes: result))
	}

	private func parseQStrings(qstrings qstrs: Array<QString>, uniqueId uid: inout Int) -> Result<CommandPipe, NSError>
	{
		/* collect all words */
		var allwords: Array<String> = []
		for qstr in qstrs {
			switch qstr {
			case .normal(let str):
				let substrs = stringToWords(source: str)
				allwords.append(contentsOf: substrs)
			case .quoted(let quoted):
				allwords.append("\"" + quoted + "\"")
			}
		}
		//NSLog("allwords: \(allwords)")

		/* device words by "|" */
		var linewords: Array<Array<String>> = []
		var curwords:  Array<String> = []
		for word in allwords {
			if word == "|" {
				if curwords.count > 0 {
					linewords.append(curwords)
					curwords = []
				}
			} else {
				curwords.append(word)
			}
		}
		if curwords.count > 0 {
			linewords.append(curwords)
			curwords = []
		}
		//NSLog("divied-words: \(linewords)")

		/* make commands */
		var commands: Array<Command> = []
		for words in linewords {
			if !words.isEmpty {
				let name = words[0]
				let args = Array(words.dropFirst())
				let cmd  = Command(uniqueId: uid, commandName: name, arguments: args)
				uid += 1 // update unique id for the command
				commands.append(cmd)
			} else {
				let err = NSError.parseError(message: "Empty command line")
				return .failure(err)
			}
		}
		return .success(CommandPipe(commands: commands))
	}

	private func stringToWords(source src: String) -> Array<String>
	{
		var result:  Array<String> = []
		var curword: String = ""

		var idx = src.startIndex
		let end = src.endIndex
		while idx < end {
			let c = src[idx]
			if c.isWhitespace {
				if !curword.isEmpty {
					result.append(curword)
					curword = ""
				}
			} else if c == "|" {
				let nxtidx = src.index(after: idx)
				if nxtidx < end {
					if src[nxtidx] == "|" {
						curword += "||"
						idx = nxtidx // forward index
					} else {
						if !curword.isEmpty {
							result.append(curword)
							curword = ""
						}
						result.append("|")
					}
				} else {
					curword += "|"
				}
			} else {
				curword += String(c)
			}
			idx = src.index(after: idx)
		}
		if !curword.isEmpty {
			result.append(curword)
			curword = ""
		}
		return result
	}
}

