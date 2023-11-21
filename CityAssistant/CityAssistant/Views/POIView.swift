//
//  POI.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI

struct POIView: View {
    @State var viewModel: POIViewModel
    @State var selectedBusiness: POI

    private var backButtonAction: (() -> Void)?

    public init(selectedBusiness: POI, viewModel: POIViewModel, onBackButton: (() -> Void )? = nil) {
        print("Creating POI view")
        self.selectedBusiness = selectedBusiness
        self.viewModel = viewModel
        self.backButtonAction = onBackButton
        
        self.selectedBusiness.Id = "4dCjF2VsM-byUGUbhYL_Ng"
        viewModel.load(business: selectedBusiness)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Group{
                if let buttonAction = backButtonAction {
                    Button(action: {buttonAction()}) {
                        Text("< Back")
                    }
                }
                VStack(alignment: .leading){
                    Text(selectedBusiness.BusinessName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Address: " +  selectedBusiness.Address.ToString())
                        .font(.body)
                    Text("Hours: " + selectedBusiness.CurrentHours)
                        .font(.body)
                    Text("Phone Number: " + (selectedBusiness.Phone ?? ""))
                        .font(.body)
                    HStack(){
                        Text("Website: ")
                        Link((selectedBusiness.Info ?? "")!, destination: URL(string: selectedBusiness.Info ?? "")!)
                            .lineLimit(1)
                    }

                    Text("Reviews:")
                        .font(.title2)
                        .bold()
                    HStack {
                        if(selectedBusiness.Rating != nil)
                        {
                            RatingStars(rating: selectedBusiness.Rating!)
                                .frame(minWidth: 1, idealWidth: 100, maxWidth: 140, minHeight: 1, idealHeight: 20, maxHeight: 20)
                            Text("\(selectedBusiness.ReviewCount)")
                                .font(.body)
                        }
                    }
                }.padding(/*@START_MENU_TOKEN@*/[.top, .bottom, .trailing]/*@END_MENU_TOKEN@*/)

                ForEach(viewModel.Reviews, id: \.self) { review in
                    ReviewCard(selectedReview: review)
                }
                Link("More Reviews on Yelp", destination: URL(string: selectedBusiness.Info ?? "")!)
            }
            Spacer()

        }.padding(/*@START_MENU_TOKEN@*/[.top, .bottom, .trailing]/*@END_MENU_TOKEN@*/).navigationBarBackButtonHidden(true)
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
        POIView(selectedBusiness: mockPOI, viewModel: mockViewModel)
    }
}
