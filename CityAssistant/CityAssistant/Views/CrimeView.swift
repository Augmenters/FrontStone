//
//  Crime.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI

struct CrimeView: View {
    let viewModel: CrimeViewModel
    
    init() {
        viewModel = CrimeViewModel()
    }
    
    var body: some View {
        AsyncContentView(source: viewModel)
        { crimeOverlays in
            ZStack()
            {
                MapView(userLocation: viewModel.userLocation,
                        overlays: crimeOverlays)
                .edgesIgnoringSafeArea(.all)
                
                TimeSlotSelector(timeSlots: viewModel.timeSlots, sliderChangedAction: viewModel.SelectTimeSlot)
            }
        }
    }
}

struct Crime_Previews: PreviewProvider {
    static var previews: some View {
        CrimeView()
    }
}
