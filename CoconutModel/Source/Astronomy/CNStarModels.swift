/**
 * @file	CNStarModels.swift
 * @brief	Define CNStarModels  class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

import Foundation

public class CNStarModels
{
	private static var mShared: CNStarModels? = nil

	public static var shared: CNStarModels { get {
		if let models = mShared {
			return models
		} else {
			let newmodels = CNStarModels()
			mShared = newmodels
			return newmodels
		}
	}}

	public struct StarModel {
		var name:	String
		var location:	CNEquatorialCoordinates

		public init(name nm: String, location loc: CNEquatorialCoordinates) {
			self.name     = nm
			self.location = loc
		}
	}

	private var mStarModels: Dictionary<String, StarModel>

	private init() {
		mStarModels = [:]
		setup()
	}

	private func setup() {
		let aldebaran = StarModel(
			name: "aldebaran",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 4, minute: 35, second: 9),
				declination: CNDegree(isPositive: true, degree: 16, minute: 31, second: 0)
			)
		)
		mStarModels[aldebaran.name] = aldebaran

		let antares = StarModel(
			name: "antares",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 16, minute: 29, second: 4),
				declination: CNDegree(isPositive: false, degree: 26, minute: 26, second: 0)
			)
		)
		mStarModels[antares.name] = aldebaran

		let bega = StarModel(
			name: "bega",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 18, minute: 36, second: 9),
				declination: CNDegree(isPositive: true, degree: 38, minute: 47, second: 0)
			)
		)
		mStarModels[bega.name] = bega

		let betelgeuse = StarModel(
			name: "betelgeuse",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 5, minute: 55, second: 2),
				declination: CNDegree(isPositive: true, degree: 7, minute: 2, second: 4)
			)
		)
		mStarModels[betelgeuse.name] = betelgeuse

		let canopus = StarModel(
			name: "canopus",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 6, minute: 24, second: 0),
				declination: CNDegree(isPositive: false, degree: 52, minute: 42, second: 0)
			)
		)
		mStarModels[canopus.name] = canopus

		let capella = StarModel(
			name: "capella",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 5, minute: 16, second: 7),
				declination: CNDegree(isPositive: true, degree: 46, minute: 0, second: 0)
			)
		)
		mStarModels[capella.name] = capella

		let deneb = StarModel(
			name: "deneb",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 20, minute: 4, second: 14),
				declination: CNDegree(isPositive: false, degree: 45, minute: 17, second: 0)
			)
		)
		mStarModels[deneb.name] = deneb

		let poratis = StarModel(
			name: "poraris",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 2, minute: 31, second: 8),
				declination: CNDegree(isPositive: true, degree: 89, minute: 16, second: 0)
			)
		)
		mStarModels[poratis.name] = poratis

		let procyon = StarModel(
			name: "procyon",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 7, minute: 39, second: 3),
				declination: CNDegree(isPositive: true, degree: 5, minute: 14, second: 0)
			)
		)
		mStarModels[procyon.name] = procyon

		let regulus = StarModel(
			name: "regulus ",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 10, minute: 8, second: 4),
				declination: CNDegree(isPositive: true, degree: 11, minute: 58, second: 0)
			)
		)
		mStarModels[regulus .name] = regulus

		let rigel = StarModel(
			name: "rigel",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 5, minute: 14, second: 5),
				declination: CNDegree(isPositive: false, degree: 8, minute: 12, second: 0)
			)
		)
		mStarModels[rigel.name] = rigel

		let sirius = StarModel(
			name: "sirius",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 6, minute: 45, second: 1),
				declination: CNDegree(isPositive: false, degree: 16, minute: 43, second: 0)
			)
		)
		mStarModels[sirius.name] = sirius

		let spica = StarModel(
			name: "spica",
			location: CNEquatorialCoordinates(
				rightAscension: CNDMS(hour: 13, minute: 25, second: 2),
				declination: CNDegree(isPositive: false, degree: 11, minute: 10, second: 0)
			)
		)
		mStarModels[spica.name] = spica
	}
}
