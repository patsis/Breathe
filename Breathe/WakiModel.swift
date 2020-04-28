//
//  WakiModel.swift
//  Breathe
//
//  Created by Harry Patsis on 19/04/2020.
//  Copyright © 2020 patsis. All rights reserved.
//

import Foundation
import Combine

public class WaqiModel: ObservableObject {
	@Published var waqi: Waqi? = nil
	@Published var working = false
	@Published var hasData = false

	fileprivate var queuedLoadStations = 0

	func load(city: String) {
		guard let url = URL(string: "https://api.waqi.info/feed/\(city)/?token=7b60f6c18df9bc648060b45f5bf8bdec9329681c") else {
			return
		}
		hasData = false
		working = true
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			do {
				DispatchQueue.main.async {
					self.working = false
					self.hasData = false
				}
				guard let jsonData = data else {
					return
				}
				let waqi = try JSONDecoder().decode(Waqi.self, from: jsonData)
				DispatchQueue.main.async {
					self.waqi = waqi
					self.hasData = true
				}
			} catch let error {
				print("failed to decode waqi data: ", error)
			}
		}.resume()
	}

	func clear() {
		waqi = nil
		self.hasData = false
	}
}

public class WaqiStationsModel: ObservableObject {
	@Published var stations: [(String, String)] = []
//	@Published var working = false
//	@Published var hasData = false//	var waqiStations: WaqiStations? = nil

	fileprivate var queuedLoadStations = 0

	func load(city: String) {
		if city.isEmpty {
			return;
		}
		/// initialize - clear
		stations = []
		queuedLoadStations += 1
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.queuedLoadStations -= 1
			if (self.queuedLoadStations > 0) {
				return
			}
			guard let url = URL(string: "https://api.waqi.info/search/?token=7b60f6c18df9bc648060b45f5bf8bdec9329681c&keyword=\(city)") else {
				return
			}
			URLSession.shared.dataTask(with: url) { (data, response, error) in
				do {
					guard let jsonData = data else {
						return
					}
					let waqiStations = try JSONDecoder().decode(WaqiStations.self, from: jsonData)
					DispatchQueue.main.async {
						guard let stationList = waqiStations.data else {
							return
						}
						for stationData in stationList {
							if let name = stationData.station?.name, let uid = stationData.uid {
								let string_uid = String("@\(uid)")
								self.stations.append((name, string_uid))
							}
						}
					}
				} catch let error {
					print("failed to decode waqi stations: ", error)
				}
			}.resume()
		}
	}

	func clear() {
		stations = []
	}


}
