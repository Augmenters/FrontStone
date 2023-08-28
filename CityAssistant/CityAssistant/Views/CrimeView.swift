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
        AsyncContentView(source: viewModel) { crimes in
            MapView(userLocation: viewModel.userLocation,
                    overlays: crimes?.map { $0.Overlay })
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct Crime_Previews: PreviewProvider {
    static var previews: some View {
        CrimeView()
    }
}
