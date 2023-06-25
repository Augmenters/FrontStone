//
//  ReviewCard.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/23/23.
//

import Foundation
import SwiftUI

struct ReviewCard: View {
    let selectedReview: Review
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("\(selectedReview.User.Name)").bold()
                RatingStars(rating: selectedReview.Rating)
                    .frame(minWidth: 1, idealWidth: 100, maxWidth: 140, minHeight: 1, idealHeight: 20, maxHeight: 20)
            }
            
            Text("\(selectedReview.Text)")
        }
    }
}

struct ReviewCard_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCard(selectedReview: Review("this is review text", 2, "Tiger Woods"))
    }
}
