/**
 * @file	CNProcess.swift
 * @brief	Define CNProcess class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation

private class CNProcessInfo
{
	private var mProcessId:	Int
	private var mProcess:	CNProcessProtocol
	private var mChildren:	Array<Int>

	public init(processId pid: Int, process proc: CNProcessProtocol) {
		mProcessId = pid
		mProcess   = proc
		mChildren  = []
	}

	public var processId: Int { get { return mProcessId }}
	public var process: CNProcessProtocol { get { return mProcess }}
	public var children: Array<Int> { get { return mChildren }}
}

public actor CNProcessManager
{
        private static var mShared: CNProcessManager = CNProcessManager()

	private var mProcesses: Dictionary<Int, CNProcessInfo>
	private var mNextProcessId: Int

        public static func addProcess(process proc: CNProcessProtocol) -> Int {
                var result: Int = 0
                Task { result = await mShared.addProcess(process: proc) }
                return result
        }

        public static func remove(processId pid: Int) {
                Task { await mShared.remove(processId: pid)}
        }

	private init() {
		mProcesses     = [:]
		mNextProcessId = 0
	}

	private func addProcess(process proc: CNProcessProtocol) -> Int {
		let newpid     =  mNextProcessId
		mNextProcessId += 1

		let newpinfo = CNProcessInfo(processId: newpid, process: proc)
		mProcesses[newpid] = newpinfo

		return newpid
	}

	private func remove(processId pid: Int) {
		if let pinfo = mProcesses[pid] {
			/* remove children */
			for cid in pinfo.children {
				remove(processId: cid)
			}
			/* remove itself */
			pinfo.process.terminate()
			mProcesses[pid] = nil
		} else {
			CNLog(logLevel: .error, message: "No process to remove", atFunction: #function, inFile: #file)
		}
	}

}

