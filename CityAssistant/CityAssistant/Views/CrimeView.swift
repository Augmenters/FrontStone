//
//  Crime.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI

struct CrimeView: View {
    @State var viewModel: CrimeViewModel
    @State private var selectedTime: Double = 0
    @State private var selectedDay: String = "Sunday"
    @State private var overlays: [OverlayObject] = []
    
    private let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    init() {
        viewModel = CrimeViewModel()
    }
    
    var body: some View {
        ZStack()
        {
            // Display the data corresponding to the selected slider value
            MapView(userLocation: viewModel.userLocation,
                    overlays: $overlays)
            .edgesIgnoringSafeArea(.all)
        }
        
        VStack (alignment: .trailing)
        {
            Spacer()
            
            HStack (alignment: .center) {

                Picker("Select Day", selection: $selectedDay) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day).tag(day)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // You can choose the picker style
                .onChange(of: selectedDay) { newValue in
                    overlays = viewModel.getData(selectedId: selectedTime, selectedDay: newValue) ?? []
                }

                Slider(value: $selectedTime, in: Double(0)...Double(3), step: Double(1)).onChange(of: selectedTime) { newValue in
                    overlays = viewModel.getData(selectedId: newValue, selectedDay: selectedDay) ?? []
                }
                
            }.background(RoundedRectangle(cornerRadius: 10.0))
        }.padding([.bottom], 90)
    }
}
