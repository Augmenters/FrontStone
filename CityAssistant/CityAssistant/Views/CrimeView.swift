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
    @State private var selectedTime: Double = 1
    @State private var overlays: [OverlayObject] = []
    
    init() {
        viewModel = CrimeViewModel()
        selectedTime = 1
    }
    
    var body: some View {
        ZStack()
        {
            // Display the data corresponding to the selected slider value
            MapView(userLocation: viewModel.userLocation,
                    overlays: $overlays)
            .edgesIgnoringSafeArea(.all)
        }.onAppear(){
            overlays = viewModel.getData(selectedId: selectedTime) ?? []
        }
        VStack (alignment: .trailing)
        {
            Spacer()
            
            HStack (alignment: .center) {
                //we could adjust the available times to be dynamic but I don't think it makes sense bc it probably wont ever change
                Slider(value: $selectedTime, in: Double(1)...Double(4), step: Double(1))
            }.background(RoundedRectangle(cornerRadius: 10.0)).onChange(of: selectedTime) { newValue in
                overlays = viewModel.getData(selectedId: newValue) ?? []
            }
        }.padding([.bottom], 90)
    }
}
