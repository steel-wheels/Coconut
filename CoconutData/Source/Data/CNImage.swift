/*
 * @file	CNImage.swift
 * @brief	Extend CNImage class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

#if os(OSX)
public typealias CNImage        = NSImage
#else
public typealias CNImage        = UIImage
#endif

public extension CNImage
{
	static let ClassName     = "Image"
	static let InterfaceName = "ImageIF"

	convenience init?(symbolName name: String) {
		#if os(OSX)
		self.init(systemSymbolName: name, accessibilityDescription: nil)
		#else
		self.init(systemName: name, withConfiguration: nil)
		#endif
	}

	static func allocateInterfaceType(sizeIF szif: CNInterfaceType, frameIF frmif: CNInterfaceType) -> CNInterfaceType {
		typealias M = CNInterfaceType.Member
		let members: Array<M> = [
			M(name: "size", type: .functionType(.stringType, []))
		]
		return CNInterfaceType(name: InterfaceName, base: frmif, members: members)
	}

	#if os(OSX)
	func pngData() -> Data? {
		if let cgimg = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
			let repl  = NSBitmapImageRep(cgImage: cgimg)
			return repl.representation(using: .png, properties: [:])
		} else {
			return nil
		}
	}
	#endif

	#if os(iOS)
	convenience init?(contentsOf url: URL) {
		self.init(contentsOfFile: url.path)
	}
	#endif

	func toValue() -> Dictionary<String, CNValue> {
		let result: Dictionary<String, CNValue> = [
			"class":	.stringValue(CNImage.ClassName),
			"size":		.interfaceValue(self.size.toValue())
		]
		return result
	}

    static func load(from url: URL) -> CNImage? {
        #if os(OSX)
        return CNImage(contentsOf: url)
        #else
        return CNImage(contentsOfFile: url.path)
        #endif
    }

    func expand(targetSize tsize: CGSize) -> CNImage? {
        let thissize = self.size
        let xdiff    = (tsize.width  - thissize.width ) / 2.0
        let ydiff    = (tsize.height - thissize.height) / 2.0
        if xdiff >= 0.0 && ydiff >= 0.0 {
            return expand(xPadding: xdiff, yPadding: ydiff)
        } else {
            return nil
        }
    }
}

#if os(OSX)
extension NSImage
{
	/* https://stackoverflow.com/questions/11949250/how-to-resize-nsimage */
	public func resize(to _size: NSSize) -> NSImage? {
		let targetsize = self.size.resizeWithKeepingAscpect(inSize: _size)
		if let bitmapRep = NSBitmapImageRep(
		    bitmapDataPlanes: nil, pixelsWide: Int(targetsize.width), pixelsHigh: Int(targetsize.height),
		    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
		    colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
		) {
		    bitmapRep.size = targetsize
		    NSGraphicsContext.saveGraphicsState()
		    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
		    draw(in: NSRect(x: 0, y: 0, width: targetsize.width, height: targetsize.height), from: .zero, operation: .copy, fraction: 1.0)
		    NSGraphicsContext.restoreGraphicsState()

		    let resizedImage = NSImage(size: targetsize)
		    resizedImage.addRepresentation(bitmapRep)
		    return resizedImage
		}
	    return nil
	}

    /* reference: https://github.com/onmyway133/blog/issues/795 */
    public func expand(xPadding: CGFloat, yPadding: CGFloat) -> CNImage {
        let srcwidth  = self.size.width
        let srcheight = self.size.height
        let newwidth  = srcwidth  + xPadding * 2.0
        let newheight = srcheight + yPadding * 2.0
        let img = CNImage(size: CGSize(width: newwidth, height: newheight))

        img.lockFocus()
            let ctx = NSGraphicsContext.current
            ctx?.imageInterpolation = .high
            self.draw(
                in:   NSMakeRect(0, 0, newwidth, newheight),
                from: NSMakeRect(-xPadding, -yPadding, newwidth, newheight),
                operation: .copy,
                fraction: 1
            )
        img.unlockFocus()

        return img
    }
}
#endif

#if os(iOS)
extension UIImage
{
	public func resize(to _size: CGSize) -> UIImage? {
		/* Copied from https://develop.hateblo.jp/entry/iosapp-uiimage-resize */

		let targetsize = self.size.resizeWithKeepingAscpect(inSize: _size)
		UIGraphicsBeginImageContextWithOptions(targetsize, false, 0.0)
		draw(in: CGRect(origin: .zero, size: targetsize))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return resizedImage
	}

    /* See https://gist.github.com/ppamorim/cc79170422236d027b2b */
    public func expand(xPadding: CGFloat, yPadding: CGFloat) -> UIImage {
        let cursize = self.size
        let targetSize = CGSize(width:  cursize.width  + xPadding * 2.0,
                                height: cursize.height + yPadding * 2.0)
        let targetOrigin = CGPoint(x: xPadding, y: yPadding)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: targetOrigin, size: self.size))
        }
    }
}
#endif

