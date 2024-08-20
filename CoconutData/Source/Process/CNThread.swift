/**
 * @file	CNThread.swift
 * @brief	Define functions to operate threads
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import Foundation

public func CNExecuteInMainThread(doSync sync: Bool, execute exec: @escaping () -> Void){
	if Thread.isMainThread {
		exec()
	} else {
		if sync {
			DispatchQueue.main.sync(execute: exec)
		} else {
			DispatchQueue.main.async(execute: exec)
		}
	}
}

public enum CNUserThreadLevel {
	case	thread
	case	event
}

public func CNExecuteInUserThread(level lvl: CNUserThreadLevel, execute exec: @escaping () -> Void){
	let qos: DispatchQoS.QoSClass
	switch lvl {
	case .thread:	qos = .utility
	case .event:	qos = .userInitiated
	}
	DispatchQueue.global(qos: qos).async {
		exec()
	}
}

public protocol CNThreadProtocol
{
	func start(arguments: Array<CNValue>)
	var  status:   CNProcessStatus { get }
	var  exitCode: CNExitCode { get }
}

open class CNThread: CNThreadProtocol
{
	public static let InterfaceName = "ThreadIF"

	private var mConsole:		CNFileConsole
	private var mEnvironment:	CNEnvironment
	private var mStatus:		CNProcessStatus
	private var mExitCode:		CNExitCode

	public var console:     	CNFileConsole	{ get { return mConsole 	}}
	public var status:		CNProcessStatus	{ get { return mStatus		}}
	public var exitCode:		CNExitCode	{ get { return mExitCode	}}
	public var environment:		CNEnvironment	{ get { return mEnvironment     }}

	public init(console cons: CNFileConsole, environment env: CNEnvironment) {
		mEnvironment	= CNEnvironment(parent: env)
		mStatus		= .idle
		mExitCode	= .runtimeError
		mConsole 	= cons
	}

	static func allocateInterfaceType() -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "start",	type: .functionType(.numberType, [.arrayType(.stringType)])),
			M(name: "status",	type: .enumType(CNProcessStatus.allocateEnumType())),
			M(name: "exitCode",	type: .numberType),
		]
		return CNInterfaceType(name: InterfaceName, base: nil, members: members)
	}

	open func start(arguments args: Array<CNValue>) {
		mStatus		= .running
		CNExecuteInUserThread(level: .thread, execute: {
			() -> Void in
			/* Enable secure access */
			let homeurl  = CNPreference.shared.userPreference.homeDirectory
			let issecure = homeurl.startAccessingSecurityScopedResource()

			/* Execute main */
			self.mExitCode = self.mainFunction(arguments: args, environment: self.mEnvironment)

			/* Disable secure access */
			if issecure {
				homeurl.stopAccessingSecurityScopedResource()
			}

			/* Finalize */
			self.closeStreams()

			switch self.mStatus {
			case .running:
				self.mStatus = .finished
			default:
				break
			}
		})
	}

	open func mainFunction(arguments args: Array<CNValue>, environment env: CNEnvironment) -> CNExitCode {
		CNLog(logLevel: .error, message: "Override this method", atFunction: #function, inFile: #file)
		return .runtimeError
	}

	private func closeStreams() {
		mConsole.outputFile.close()
		mConsole.errorFile.close()
	}
}

