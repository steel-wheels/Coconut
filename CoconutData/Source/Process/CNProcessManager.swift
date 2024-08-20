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

public class CNProcessManager
{
	private static var mShared: CNProcessManager? = nil

	public static var shared: CNProcessManager {
		if let pmgr = mShared {
			return pmgr
		} else {
			let newmgr = CNProcessManager()
			mShared = newmgr
			return newmgr
		}
	}

	private var mProcesses: Dictionary<Int, CNProcessInfo>
	private var mNextProcessId: Int

	private init() {
		mProcesses     = [:]
		mNextProcessId = 0
	}

	public func addProcess(process proc: CNProcessProtocol) -> Int {
		let newpid     =  mNextProcessId
		mNextProcessId += 1

		let newpinfo = CNProcessInfo(processId: newpid, process: proc)
		mProcesses[newpid] = newpinfo

		return newpid
	}

	public func remove(processId pid: Int) {
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

/*
public class CNProcessManager
{
	private var 	mNextProcessId:		Int
	private var	mProcesses:		Dictionary<Int, CNProcessProtocol>
	private var 	mChildProcessManager:	Array<CNProcessManager>

	public var childProcessManagers: Array<CNProcessManager> { get { return mChildProcessManager }}

	public init() {
		mNextProcessId		= 0
		mProcesses		= [:]
		mChildProcessManager	= []
	}

	public func addProcess(process proc: CNProcessProtocol) -> Int {
		let pid = mNextProcessId
		mProcesses[pid] = proc
		mNextProcessId  += 1
		return pid
	}

	public func removeProcess(process proc: CNProcessProtocol) {
		if let pid = proc.processId {
			mProcesses.removeValue(forKey: pid)
		} else {
			CNLog(logLevel: .error, message: "Process with no pid", atFunction: #function, inFile: #file)
		}
	}

	public func addChildManager(childManager mgr: CNProcessManager){
		mChildProcessManager.append(mgr)
	}

	public func terminate() {
		/* Terminate children first */
		for child in mChildProcessManager {
			child.terminate()
		}
		/* Terminate all processes */
		for process in mProcesses.values {
			process.terminate()
		}
	}
}
*/

