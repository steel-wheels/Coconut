/**
 * @file	CNTimer.swift
 * @brief	Define CNTimer class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import Foundation
#if os(OSX)
	import Cocoa
#endif
#if os(iOS)
	import UIKit
#endif


public class CNTimer
{
	/* The return value presents true:  Do continue the loop
	 *                           false: Do Not contiue
	 */
	public typealias TimerHandler		= (_ time: Int) -> Bool

	private var mTimer:			Timer?
	private var mInterval:			TimeInterval
	private var mRepeatCount:		Int
	private var mTimerHandlers:		Array<TimerHandler>
	private var mIsActive:			Bool

	public init(interval intvl: TimeInterval) {
		mTimer			= nil
		mInterval		= intvl
		mRepeatCount		= 0
		mTimerHandlers		= []
		mIsActive		= false
	}

	deinit {
		stop()
	}

	public var interval: TimeInterval {
		get		{ return mInterval }
		set(newval)	{
			if self.isActive {
				self.stop()
			}
			mInterval = newval
		}
	}

	public var isActive: Bool {
		get { return mIsActive }
	}

	public func addTimerHandler(handler hdlr: @escaping TimerHandler) {
		mTimerHandlers.append(hdlr)
	}

	public func start(){
		if mTimer == nil {
			mTimer       = Timer.scheduledTimer(timeInterval: mInterval, target: self, selector: #selector(CNTimer.update(_:)), userInfo: nil, repeats: true)
			mIsActive    = true
			mRepeatCount = 0
			if let timer = mTimer {
				RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
			}
		}
	}

	public func stop() {
		if let timer = mTimer {
			timer.invalidate()
			mTimer    = nil
			mIsActive = false
		}
	}

	@objc func update(_ timer: Timer){
		guard timer.isValid else {
			mIsActive = false
			return
		}

		/* Execute repetitive handlers */
		var dofinish: Bool = false
		for cbfunc in mTimerHandlers {
			if(!cbfunc(mRepeatCount)){
				dofinish = true
			}
		}
		if dofinish {
			stop()
		} else {
			if mRepeatCount == Int32.max {
				mRepeatCount = 1
			} else {
				mRepeatCount += 1
			}
		}
	}
}

