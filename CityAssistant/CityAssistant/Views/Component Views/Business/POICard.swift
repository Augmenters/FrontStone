//
//  POICard.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/24/23.
//

import Foundation
import SwiftUI

struct POICard: View {
    let poi: POI
    var body: some View {
        VStack (alignment: .leading) {
            Text("\(poi.BusinessName)").bold()
            Text("\(poi.Address.ToString())")
        }
    }
}

struct POICard_Previews: PreviewProvider {
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    
    static var previews: some View {
        POICard(poi: mockPOI)
    }
}
