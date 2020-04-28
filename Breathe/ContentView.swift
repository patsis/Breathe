//
//  ContentView.swift
//  Breathe
//
//  Created by Harry Patsis on 17/04/2020.
//  Copyright © 2020 patsis. All rights reserved.
//


// token: 7b60f6c18df9bc648060b45f5bf8bdec9329681c
// https://api.waqi.info/feed/here/?token=7b60f6c18df9bc648060b45f5bf8bdec9329681c
import SwiftUI

func getColor(_ attr: Double) -> Color {
	switch attr {
	case 0...50:
		return Color(red: 0, green: 153 / 255, blue: 102 / 255)
	case 51...100:
		return Color(red: 1, green: 222 / 255, blue: 51 / 255)
	case 101...150:
		return Color(red: 1, green: 153 / 255, blue: 51 / 255)
	case 151...200:
		return Color(red: 204 / 255, green: 0, blue: 51 / 255)
	case 201...300:
		return Color(red: 102 / 255, green: 0, blue: 153 / 255)
	default:
		return Color(red: 126 / 255, green: 0, blue: 35 / 255)
	}
}

struct ColorizedRect: View {
	@State var attr: Double = 0
	var body: some View {
		ZStack {
			Rectangle()
				.fill(getColor(attr))
				.frame(maxHeight: 100)
				.cornerRadius(5, antialiased: true)
				.padding([.leading, .trailing], 50)
			Text(String(format: "%g", attr))
				.font(.system(size: 40))
				.foregroundColor(.black)
		}
	}
}

struct Attribute: Identifiable {
	var id = UUID()
	let label: String
	let attr: String
}

struct AttrRow: View {
	let label: String
	let attr: String
	let waqi: Waqi?
	var value: Double? { waqi?.attr(attribute: attr) }
	let _width1: CGFloat = 150
	let _width2: CGFloat = 50
	let _fontSize: CGFloat = 15
	var body: some View {
		HStack {
			if (value != nil) {
				Text(label+":")
					.font(.system(size: _fontSize))
					.foregroundColor(Color("results_f"))
					.frame(width: _width1, alignment: .leading)
				Text(String(format: "%g", value!))
					.font(.system(size: _fontSize))
					.foregroundColor(Color("results_f"))
					.frame(width: _width2, alignment: .trailing)
			}
		}
	}
}

//MARK: Results View
struct ResultsView: View {
	@State var waqi: Waqi?

	var attributes : [Attribute] { [
		Attribute(label: "PM2.5", attr: "pm25"),
		Attribute(label: "PM10", attr: "pm10"),
		Attribute(label: "Temperature", attr: "t"),
		Attribute(label: "Relative Humidity", attr: "h"),
		Attribute(label: "Wind", attr: "w"),
		Attribute(label: "Rain (precitipation)", attr: "r"),
		Attribute(label: "Pressure", attr: "p"),
		Attribute(label: "Dew", attr: "d"),
		Attribute(label: "Ozone", attr: "o3"),
		Attribute(label: "Carbon Monoxyde", attr: "co"),
		Attribute(label: "Nitrogen Dioxide", attr: "no2"),
		Attribute(label: "Sulphur Dioxide", attr: "so2")
		]
	}

	var body: some View {
		VStack {
			ZStack {
				/// background
				Rectangle()
					.fill(Color("results_b"))
					.frame(maxWidth: . infinity, maxHeight: .infinity)
					.cornerRadius(10, antialiased: true)
					.shadow(radius: 1)

				if waqi != nil {
					VStack {
						Group {
							///Station name
							if waqi?.city() != nil {
								Text(waqi!.city()!)
									.font(.headline)
									.foregroundColor(Color("results_f"))
							}
							/// Station time
							if waqi?.time != nil {
								Text(waqi!.time()!)
									.foregroundColor(Color("results_f"))
							}
							/// quality pm25 colorized
							if waqi?.attr(attribute: "dominent") != nil {
								ColorizedRect(attr: (waqi?.attr(attribute: "dominent"))!)
							}
							/// quality description
							if (waqi?.qualityDescription() != nil) {
								Text(waqi!.qualityDescription()!)
									.font(.headline)
									.foregroundColor(Color("results_f"))
									.padding(.bottom)
							}
						}
						ScrollView {
							ForEach(attributes) { attr in
								AttrRow(label: attr.label, attr: attr.attr, waqi: self.waqi)
							}
						}
						Spacer()
					}
					.padding()
				} else {
					Text("Error Loading Data...")
				}

			}
		}
		.padding([.leading, .trailing, .bottom])
	}
}

//MARK: Main View
struct ContentView: View {
	@ObservedObject var waqiModel: WaqiModel
	@State var useHere: Bool
	@State var city: String
	@State var station: String
	@State var pulseAtMaxScale = false
	@State var showSettings = false
	private let TitleHeight: CGFloat = 200
	private let pulseAnimation = Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
	private let rotateAnimationStart = Animation.linear(duration: 2).repeatForever(autoreverses: false)
	private let rotateAnimationStop = Animation.linear(duration: 0)

	func loadData() {
		var parameter = ""
		if self.useHere {
			parameter = "here"
		} else if (self.station.isEmpty) {
			parameter = self.city
		} else {
			parameter = self.station
		}
		self.waqiModel.load(city: parameter)
	}

	var body: some View {
		ZStack { /// Full screen ZStack (needed for Gear View
			ZStack { /// All except gear
				VStack {
					Rectangle()
						.fill(LinearGradient(gradient: Gradient(colors: [Color("title_b1"), Color("title_b2")]), startPoint: .topLeading, endPoint: .bottomTrailing))
						.frame(maxWidth: .infinity, maxHeight: TitleHeight)
						.cornerRadius(10, antialiased: true)
						.shadow(radius: 5)
						.offset(x: 0, y: -10)
					Spacer()
				}

				VStack { /// VStack for TitleView, RefreshButton and ResultsView)
					Spacer()
						.frame(height: 60)

					HStack() {
						Image(systemName: "heart.fill")
							.scaleEffect(pulseAtMaxScale ? 1.3 : 1)
							.onAppear { withAnimation(self.pulseAnimation, { self.pulseAtMaxScale.toggle() }) }
							.foregroundColor(Color("title_f"))
							.padding(.trailing, 10)

						Text("Breathe")
							.font(.title)
							.foregroundColor(Color("title_f"))
					}

					Text("Air quality on spot!")
						.foregroundColor(Color("title_f"))
						.padding()

					//MARK: Refresh Button and Action
					Button(action: {
						self.loadData()
					}) {
						//MARK: Refresh button contents
						VStack {
							HStack() {
								Image(systemName: self.waqiModel.working ? "arrow.2.circlepath" : "arrow.clockwise")
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: 20, height: 20)
									.foregroundColor(Color("refresh_f"))
									.animation(nil) /// do not animate above
									.rotationEffect(Angle(degrees: self.waqiModel.working ? 360 : 0))
									.animation(self.waqiModel.working ? self.rotateAnimationStart : self.rotateAnimationStop)

								Text("Refresh")
									.foregroundColor(Color("refresh_f"))
									.fixedSize(horizontal: true, vertical: false)
							}
							.padding(12)
							.background(Color("refresh_b"))
							.cornerRadius(50, antialiased: true)
							.shadow(radius: 5)
						}
					}

					//MARK: ResultView added
					if (self.waqiModel.hasData) {
					ResultsView(waqi: waqiModel.waqi)
							.transition(AnyTransition.opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.2)))
					} else {
						Spacer()
					}
				}
			} /// VStack that contains all content except gear (Title View, Refresh Vutton and Result View)
				.edgesIgnoringSafeArea(.top)

			VStack { /// Contains Gear View
				HStack {
					Spacer()
					Button(action: {
						self.showSettings.toggle()
					}) {
					Image(systemName: "gear")
						.foregroundColor(Color("title_f"))
						.padding()
					}.sheet(isPresented: $showSettings, onDismiss: {
						self.loadData()
					}) {
						SettingsView(showSettings: self.$showSettings, useHere: self.$useHere, city: self.$city, station: self.$station)
					}
				}
				Spacer()
			}

		} /// Full screen ZStack
			.background(LinearGradient(gradient: Gradient(colors: [Color("bcolor1"), Color("bcolor2")]), startPoint: .top, endPoint: .bottom))
	}
}




struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(waqiModel: WaqiModel(), useHere: true, city: "", station: "")
			.environment(\.colorScheme, .dark)
	}
}
