//
//  Waqi.swift
//  Breathe
//
//  Created by Harry Patsis on 19/04/2020.
//  Copyright © 2020 patsis. All rights reserved.
//

import Foundation

// MARK: - Waqi
struct Waqi: Codable {
//	let id: Int
	let status: String?
	let data: WaqiData?

	func city() -> String? {
		return data?.city?.name
	}

	func time() -> String? {
		guard let v = data?.time?.v else {
			return nil
		}
		let t = TimeInterval(v)
		let offset = TimeInterval(TimeZone.current.secondsFromGMT())
		let date = Date.init(timeIntervalSince1970: t - offset)
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let string = formatter.localizedString(for: date, relativeTo: Date())
		return string
	}

	func attr(attribute: String) -> Double? {
		switch attribute {
		case "dominent":
			let dom = data?.dominentpol ?? "pm25"
			return attr(attribute: dom)
		case "pm25":
			return data?.iaqi?.pm25?.v
		case "pm10":
			return data?.iaqi?.pm10?.v
		case "co":
			return data?.iaqi?.co?.v
		case "h":
			return data?.iaqi?.h?.v
		case "no2":
			return data?.iaqi?.no2?.v
		case "o3":
			return data?.iaqi?.o3?.v
		case "r":
			return data?.iaqi?.r?.v
		case "d":
			return data?.iaqi?.d?.v
		case "p":
			return data?.iaqi?.p?.v
		case "so2":
			return data?.iaqi?.so2?.v
		case "t":
			return data?.iaqi?.t?.v
		case "w":
			return data?.iaqi?.w?.v
		default:
			return nil
		}
	}

	func qualityDescription() -> String? {
		guard let attr = data?.iaqi?.pm25?.v  else {
			return nil
		}
		switch attr {
		case 0...50:
			return "Good"
		case 51...100:
			return "Moderate"
		case 101...150:
			return "Unhealthy for Sensitive Groups"
		case 151...200:
			return "Unhealthy"
		case 201...300:
			return "Very Unhealthy"
		default:
			return "Hazardous"
		}
	}


}

// MARK: - DataClass
struct WaqiData: Codable {
	let idx, aqi: Int?
	let time: WaqiTime?
	let city: WaqiCity?
	let dominentpol: String?
	let iaqi: Iaqi?
}

// MARK: - City
struct WaqiCity: Codable {
	let name: String?
	let url: String?
	let geo: [Double]
}

// MARK: - Iaqi
struct Iaqi: Codable {
	let co, h, no2, o3: WaqiAttr?
	let r, d, p, pm10: WaqiAttr?
	let pm25, so2, t, w: WaqiAttr?
}

// MARK: - Co
struct WaqiAttr: Codable {
	let v: Double?
}

// MARK: - Time
struct WaqiTime: Codable {
	let s, tz: String?
	let v: Int?
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// MARK: - WaqiStations
struct WaqiStations: Codable {
    let status: String?
    let data: [StationData]?
}

// MARK: - Datum
struct StationData: Codable {
    let uid: Int?
    let aqi: String?
    let time: WaqiTime?
    let station: Station?
}

// MARK: - Station
struct Station: Codable {
    let name: String?
    let geo: [Double]?
    let url, country: String?
}

//// MARK: - Time
//struct Time: Codable {
//    let tz, stime: String?
//    let vtime: Int?
//}
