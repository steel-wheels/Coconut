/**
 * @file	CNEquatorialCoordinate.swift
 * @brief	Define CNEquatorialCoordinate class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public struct CNEquatorialCoordinates {
	public var rightAscension:	CNDMS
	public var declination:		CNDegree

	public init(rightAscension ra: CNDMS, declination dec: CNDegree) {
		self.rightAscension	= ra
		self.declination	= dec
	}
}
