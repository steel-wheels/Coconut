/*
 * @file	CNFileHandle.swift
 * @brief	Define CNFileHandle class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import Foundation
import Darwin.POSIX.termios
import Darwin

// see https://stackoverflow.com/a/24335355/669586
private func initStruct<S>() -> S {
	let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
	let struct_memory = struct_pointer.pointee
	struct_pointer.deallocate()
	return struct_memory
}

private func enableRawMode(fileHandle: FileHandle, enable en: Bool){
	var raw: termios = initStruct()
	tcgetattr(fileHandle.fileDescriptor, &raw)
	if en {
		raw.c_lflag &= ~(UInt(ECHO | ICANON))
	} else {
		raw.c_lflag |=  (UInt(ECHO | ICANON))
	}
	tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw);
}

extension FileHandle
{
	public func write(string str: String) {
		if let data = str.data(using: .utf8) {
			self.write(data)
		} else {
			CNLog(logLevel: .error, message: "Failed to convert", atFunction: #function, inFile: #file)
		}
	}

	public var availableString: String { get {
		let data = self.availableData
		if let str = String.stringFromData(data: data) {
			return str
		} else {
			CNLog(logLevel: .error, message: "Failed to convert", atFunction: #function, inFile: #file)
			return ""
		}
	}}

        /* https://stackoverflow.com/questions/7505777/how-do-i-check-for-nsfilehandle-has-data-available */
        public func hasAvailableData() -> Bool {
                var fdset = fd_set()
                FileDescriptor.fdZero(&fdset)
                FileDescriptor.fdSet(fileDescriptor, set: &fdset)
                var tmout = timeval()
                let status = select(fileDescriptor + 1, &fdset, nil, nil, &tmout)
                return status > 0
        }

	public func closeHandle() -> NSError? {
		do {
			try self.close()
			return nil
		} catch {
			return NSError.fileError(message: "Failed to close fileHandle")
		}
	}

	public func setRawMode(enable en: Bool){
		enableRawMode(fileHandle: self, enable: en)
	}
}

/* https://stackoverflow.com/questions/7505777/how-do-i-check-for-nsfilehandle-has-data-available */
private struct FileDescriptor {

   public static func fdZero(_ set: inout fd_set) {
      set.fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
   }

   public static func fdSet(_ fd: Int32, set: inout fd_set) {
      let intOffset = Int32(fd / 32)
      let bitOffset = fd % 32
      let mask = Int32(1) << bitOffset
      switch intOffset {
      case 0: set.fds_bits.0 = set.fds_bits.0 | mask
      case 1: set.fds_bits.1 = set.fds_bits.1 | mask
      case 2: set.fds_bits.2 = set.fds_bits.2 | mask
      case 3: set.fds_bits.3 = set.fds_bits.3 | mask
      case 4: set.fds_bits.4 = set.fds_bits.4 | mask
      case 5: set.fds_bits.5 = set.fds_bits.5 | mask
      case 6: set.fds_bits.6 = set.fds_bits.6 | mask
      case 7: set.fds_bits.7 = set.fds_bits.7 | mask
      case 8: set.fds_bits.8 = set.fds_bits.8 | mask
      case 9: set.fds_bits.9 = set.fds_bits.9 | mask
      case 10: set.fds_bits.10 = set.fds_bits.10 | mask
      case 11: set.fds_bits.11 = set.fds_bits.11 | mask
      case 12: set.fds_bits.12 = set.fds_bits.12 | mask
      case 13: set.fds_bits.13 = set.fds_bits.13 | mask
      case 14: set.fds_bits.14 = set.fds_bits.14 | mask
      case 15: set.fds_bits.15 = set.fds_bits.15 | mask
      case 16: set.fds_bits.16 = set.fds_bits.16 | mask
      case 17: set.fds_bits.17 = set.fds_bits.17 | mask
      case 18: set.fds_bits.18 = set.fds_bits.18 | mask
      case 19: set.fds_bits.19 = set.fds_bits.19 | mask
      case 20: set.fds_bits.20 = set.fds_bits.20 | mask
      case 21: set.fds_bits.21 = set.fds_bits.21 | mask
      case 22: set.fds_bits.22 = set.fds_bits.22 | mask
      case 23: set.fds_bits.23 = set.fds_bits.23 | mask
      case 24: set.fds_bits.24 = set.fds_bits.24 | mask
      case 25: set.fds_bits.25 = set.fds_bits.25 | mask
      case 26: set.fds_bits.26 = set.fds_bits.26 | mask
      case 27: set.fds_bits.27 = set.fds_bits.27 | mask
      case 28: set.fds_bits.28 = set.fds_bits.28 | mask
      case 29: set.fds_bits.29 = set.fds_bits.29 | mask
      case 30: set.fds_bits.30 = set.fds_bits.30 | mask
      case 31: set.fds_bits.31 = set.fds_bits.31 | mask
      default: break
      }
   }

   public static func fdClr(_ fd: Int32, set: inout fd_set) {
      let intOffset = Int32(fd / 32)
      let bitOffset = fd % 32
      let mask = ~(Int32(1) << bitOffset)
      switch intOffset {
      case 0: set.fds_bits.0 = set.fds_bits.0 & mask
      case 1: set.fds_bits.1 = set.fds_bits.1 & mask
      case 2: set.fds_bits.2 = set.fds_bits.2 & mask
      case 3: set.fds_bits.3 = set.fds_bits.3 & mask
      case 4: set.fds_bits.4 = set.fds_bits.4 & mask
      case 5: set.fds_bits.5 = set.fds_bits.5 & mask
      case 6: set.fds_bits.6 = set.fds_bits.6 & mask
      case 7: set.fds_bits.7 = set.fds_bits.7 & mask
      case 8: set.fds_bits.8 = set.fds_bits.8 & mask
      case 9: set.fds_bits.9 = set.fds_bits.9 & mask
      case 10: set.fds_bits.10 = set.fds_bits.10 & mask
      case 11: set.fds_bits.11 = set.fds_bits.11 & mask
      case 12: set.fds_bits.12 = set.fds_bits.12 & mask
      case 13: set.fds_bits.13 = set.fds_bits.13 & mask
      case 14: set.fds_bits.14 = set.fds_bits.14 & mask
      case 15: set.fds_bits.15 = set.fds_bits.15 & mask
      case 16: set.fds_bits.16 = set.fds_bits.16 & mask
      case 17: set.fds_bits.17 = set.fds_bits.17 & mask
      case 18: set.fds_bits.18 = set.fds_bits.18 & mask
      case 19: set.fds_bits.19 = set.fds_bits.19 & mask
      case 20: set.fds_bits.20 = set.fds_bits.20 & mask
      case 21: set.fds_bits.21 = set.fds_bits.21 & mask
      case 22: set.fds_bits.22 = set.fds_bits.22 & mask
      case 23: set.fds_bits.23 = set.fds_bits.23 & mask
      case 24: set.fds_bits.24 = set.fds_bits.24 & mask
      case 25: set.fds_bits.25 = set.fds_bits.25 & mask
      case 26: set.fds_bits.26 = set.fds_bits.26 & mask
      case 27: set.fds_bits.27 = set.fds_bits.27 & mask
      case 28: set.fds_bits.28 = set.fds_bits.28 & mask
      case 29: set.fds_bits.29 = set.fds_bits.29 & mask
      case 30: set.fds_bits.30 = set.fds_bits.30 & mask
      case 31: set.fds_bits.31 = set.fds_bits.31 & mask
      default: break
      }
   }

   public static func fdIsSet(_ fd: Int32, set: inout fd_set) -> Bool {
      let intOffset = Int(fd / 32)
      let bitOffset = fd % 32
      let mask = Int32(1) << bitOffset
      switch intOffset {
      case 0: return set.fds_bits.0 & mask != 0
      case 1: return set.fds_bits.1 & mask != 0
      case 2: return set.fds_bits.2 & mask != 0
      case 3: return set.fds_bits.3 & mask != 0
      case 4: return set.fds_bits.4 & mask != 0
      case 5: return set.fds_bits.5 & mask != 0
      case 6: return set.fds_bits.6 & mask != 0
      case 7: return set.fds_bits.7 & mask != 0
      case 8: return set.fds_bits.8 & mask != 0
      case 9: return set.fds_bits.9 & mask != 0
      case 10: return set.fds_bits.10 & mask != 0
      case 11: return set.fds_bits.11 & mask != 0
      case 12: return set.fds_bits.12 & mask != 0
      case 13: return set.fds_bits.13 & mask != 0
      case 14: return set.fds_bits.14 & mask != 0
      case 15: return set.fds_bits.15 & mask != 0
      case 16: return set.fds_bits.16 & mask != 0
      case 17: return set.fds_bits.17 & mask != 0
      case 18: return set.fds_bits.18 & mask != 0
      case 19: return set.fds_bits.19 & mask != 0
      case 20: return set.fds_bits.20 & mask != 0
      case 21: return set.fds_bits.21 & mask != 0
      case 22: return set.fds_bits.22 & mask != 0
      case 23: return set.fds_bits.23 & mask != 0
      case 24: return set.fds_bits.24 & mask != 0
      case 25: return set.fds_bits.25 & mask != 0
      case 26: return set.fds_bits.26 & mask != 0
      case 27: return set.fds_bits.27 & mask != 0
      case 28: return set.fds_bits.28 & mask != 0
      case 29: return set.fds_bits.29 & mask != 0
      case 30: return set.fds_bits.30 & mask != 0
      case 31: return set.fds_bits.31 & mask != 0
      default: return false
      }
   }
}

