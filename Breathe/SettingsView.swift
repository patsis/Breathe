//
//  SettingsView.swift
//  Breathe
//
//  Created by Harry Patsis on 23/04/2020.
//  Copyright © 2020 patsis. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var waqiStationsModel = WaqiStationsModel()
	@Binding var showSettings: Bool
	@Binding var useHere: Bool
	@Binding var city: String
	@Binding var station: String
//	@State var selected:Int = -1
	var body: some View {
		NavigationView {
			VStack {
				Text("Select location to show air quality")
					.font(.body)
					.foregroundColor(Color("results_f"))
					.padding()
				Toggle(isOn: $useHere) {
					Text("Use your location")
						.foregroundColor(Color("results_f"))
				}
				TextField("Enter a city", text: $city, onEditingChanged: {change in
					self.waqiStationsModel.load(city: self.city)
				})
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.foregroundColor(Color("results_f"))
					.disabled(useHere)
					.onAppear() {
						if !self.useHere {
							self.waqiStationsModel.load(city: self.city)
						}
				}
				Text("Enter a city, place or location name")
					.font(.callout)
					.foregroundColor(Color("results_fg"))

				if (waqiStationsModel.stations.count > 0) {
					VStack(alignment: .leading, spacing: 5) {
						Text("Available stations:")
							.bold()
							.foregroundColor(Color("results_f"))
						ScrollView {
						Divider()
							.padding([.leading, .trailing])
						ForEach(0..<waqiStationsModel.stations.count) { i in
							Button(action: {
//								self.selected = i
								if self.station == self.waqiStationsModel.stations[i].1  {
									self.station = ""
								} else {
									self.station = self.waqiStationsModel.stations[i].1
								}
							}) {
								HStack {
									Text(self.waqiStationsModel.stations[i].0)
										.foregroundColor(Color("results_f"))
									Spacer()
									Image(systemName: "checkmark")
										.opacity(self.waqiStationsModel.stations[i].1 == self.station ? 1 : 0)
//										.opacity(self.selected == i ? 1 : 0)
								}

							}
							Divider()
						}
						.padding([.leading, .trailing])
						}
					}
					.padding(.top)


				}
				Spacer()
				Text("All data are provided by World Air Quality Index")
					.font(.footnote)
					.foregroundColor(Color("results_fg"))
				Button("https://waqi.info")
				{UIApplication.shared.open(URL(string: "https://waqi.info")!)}
					.font(.footnote)
			}
			.padding()
			.background(Color("results_b"))
			.navigationBarTitle(Text("Settings"), displayMode: .inline)
			.navigationBarItems(trailing: Button(action: {
				self.showSettings = false
			}) {
				Text("Done").bold()
			})
		}
	}
}

struct SettingsView_Previews: PreviewProvider {
	@State static var show = true
	@State static var city = "Rome"
	@State static var here = false
	@State static var station = ""
	static var previews: some View {
		SettingsView(showSettings: $show, useHere: $here, city: $city, station: $station)
			.environment(\.colorScheme, .dark)
	}
}
