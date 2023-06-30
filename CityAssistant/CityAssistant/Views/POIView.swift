//
//  POI.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI

struct POIView: View {
    @ObservedObject var viewModel: POIViewModel
    
    var body: some View {
        AsyncContentView(source: viewModel) { reviews in
            VStack(alignment: .leading) {
                Group{
                    VStack(alignment: .leading){
                        Text(viewModel.SelectedBusiness.BusinessName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        HStack {
                            Text("Business Type")
                                .font(.title2)
                                .padding(.bottom)
                            Text((viewModel.SelectedBusiness.Price ?? ""))
                                .font(.title2)
                                .padding(.bottom)
                        }
                        Text("Address: " +  viewModel.SelectedBusiness.Address.ToString())
                            .font(.body)
                        Text("Hours: " + "8 am to 9 pm")
                            .font(.body)
                        Text("Phone Number: " + viewModel.SelectedBusiness.Phone)
                            .font(.body)
                        Text("Website: " + ( viewModel.SelectedBusiness.Info ?? ""))
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("Reviews:")
                            .font(.title2)
                            .bold()
                        HStack {
                            if(viewModel.SelectedBusiness.Rating != nil)
                            {
                                RatingStars(rating: viewModel.SelectedBusiness.Rating!)
                                    .frame(minWidth: 1, idealWidth: 100, maxWidth: 140, minHeight: 1, idealHeight: 20, maxHeight: 20)
                                Text("\(viewModel.SelectedBusiness.ReviewCount)")
                                    .font(.body)
                            }
                        }
                    }.padding(/*@START_MENU_TOKEN@*/[.top, .bottom, .trailing]/*@END_MENU_TOKEN@*/)
                    
                    ForEach(reviews!, id: \.self) { review in
                        ReviewCard(selectedReview: review)
                    }
                    Text("More reviews on Yelp")
                        .foregroundColor(Color.blue)
                        
                }
                Spacer()
                
            }
            .padding(/*@START_MENU_TOKEN@*/[.top, .bottom, .trailing]/*@END_MENU_TOKEN@*/)
            
        }
    }
}

struct POI_Previews: PreviewProvider {
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    
    static var previews: some View {
        POIView(viewModel: mockViewModel)
    }
}
