/*
 * @file        CNSharedObject.swift
 * @brief       Define CNSharedCounter class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

public actor CNSharedCounter
{
        private var mCounter: Int

        public var value: Int { get { return mCounter }}

        public  init() {
                mCounter = 0
        }

        public func increment() -> Int {
                let result = mCounter
                mCounter += 1
                return result
        }

        public static func count(of obj: CNSharedCounter) -> Int {
                var count = 0
                Task { count = await obj.value }
                return count
        }

        public static func increment(of obj: CNSharedCounter) {
                Task { await obj.increment() }
        }
}

public actor CNUniqueIdentifier
{
        private var mIdentifier:        String
        private var mCount:             Int

        public init(identifier ident: String){
                mIdentifier     = ident
                mCount          = 0
        }

        public func value() -> String {
                let ident = mIdentifier + "_\(mCount)"
                mCount += 1
                return ident
        }

        public static func identifier(in obj: CNUniqueIdentifier) -> String {
                var result: String = ""
                Task { result = await obj.value() }
                return result
        }
}
