/**
 * @file	CNProcess.swift
 * @brief	Define CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

public enum CNProcessStatus: Int
{
	public static let TypeName = "ProcessStatus"

	case idle	= 0
	case running	= 1
	case finished	= 2
	case cancelled	= 3

	public static func allocateEnumType() -> CNEnumType {
		let procstate = CNEnumType(typeName: CNProcessStatus.TypeName)
		procstate.add(members: [
			"idle":			.intValue(CNProcessStatus.idle.rawValue),
			"running":		.intValue(CNProcessStatus.running.rawValue),
			"finished":		.intValue(CNProcessStatus.finished.rawValue),
			"cancelled":		.intValue(CNProcessStatus.cancelled.rawValue)
		])
		return procstate
	}

	public var isRunning: Bool { get {
		let result: Bool
		switch self {
		case .idle:		result = false
		case .running:		result = true
		case .finished:		result = false
		case .cancelled:	result = false
		}
		return result
	}}

	public var isStopped: Bool { get {
		let result: Bool
		switch self {
		case .idle:		result = false
		case .running:		result = false
		case .finished:		result = true
		case .cancelled:	result = true
		}
		return result
	}}

	public var description: String { get {
		let result: String
		switch self {
		case .idle:		result = "idle"
		case .running:		result = "running"
		case .finished:		result = "finished"
		case .cancelled:	result = "cancelled"
		}
		return result
	}}
}

public protocol CNProcessProtocol
{
	var 	processId:	Int { get }
	var	console: 	CNFileConsole { get }

	var 	status:			CNProcessStatus { get }
	var	terminationStatus:	Int32 { get }

	func terminate()
}

#if os(OSX)

open class CNProcess: CNProcessProtocol
{
	public static let InterfaceName		= "ProcessIF"

	public typealias TerminationHandler	= (_ proc: Process) -> Void

	private var mProcessId:			Int
	private var mStatus:			CNProcessStatus
	private var mProcess:			Process
	private var mConsole:			CNFileConsole
	private var mTerminationHandler:	TerminationHandler?

	public var console:		CNFileConsole	{ get { return mConsole 			}}
	public var status: 		CNProcessStatus { get { return mStatus 				}}
	public var terminationStatus:	Int32		{ get { return mProcess.terminationStatus	}}

	public var processId: Int {
		get { return mProcessId }
	}

	public init(input ifile: CNInputFile, output ofile: CNOutputFile, error efile: CNOutputFile, terminationHander termhdlr: TerminationHandler?)
	{
		mProcessId		= 0 // will be overwrite
		mStatus			= .idle
		mProcess		= Process()
		mTerminationHandler	= termhdlr
		mConsole		= CNFileConsole(input: ifile, output: ofile, error: efile)

		mProcessId = CNProcessManager.addProcess(process: self)

		mProcess.standardInput		= ifile.fileHandle
		mProcess.standardOutput		= ofile.fileHandle
		mProcess.standardError		= efile.fileHandle
		mProcess.environment		= CNEnvironment.shared.getAll()
		mProcess.currentDirectoryURL	= CNEnvironment.shared.currentDirectory
		mProcess.terminationHandler = {
			[weak self] (process: Process) -> Void in
			if let myself = self {
				/* Update status */
				myself.mStatus = .finished
				/* Restore reader handler */
				myself.closeStreams()
				/* Call handler */
				if let handler = myself.mTerminationHandler {
					handler(myself.mProcess)
				}
			}
		}
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "isRunning",	type: .boolType),
			M(name: "didFinished",	type: .boolType),
			M(name: "exitCode",	type: .numberType),
			M(name: "terminate",	type: .functionType(.voidType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	deinit {
		/* Remove from parent */
		CNProcessManager.remove(processId: mProcessId)
	}

	public func execute(command cmd: String) {
		/* Enable secure access */
		let docurl   = FileManager.default.documentDirectory
		let issecure = docurl.startAccessingSecurityScopedResource()

		mStatus			= .running
		mProcess.launchPath	= "/bin/sh"
		mProcess.arguments	= ["-c", cmd]
		mProcess.launch()

		/* Disable secure access */
		if issecure {
			docurl.stopAccessingSecurityScopedResource()
		}
	}

	open func terminate() {
		if mProcess.isRunning {
			mProcess.terminate()
		}
	}


	private func closeStreams() {
		mConsole.outputFile.close()
		mConsole.errorFile.close()
	}
}

#endif

