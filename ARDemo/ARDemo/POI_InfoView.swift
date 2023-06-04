//
//  POI_InfoView.swift
//  ARDemo
//
//  Created by Justin Reini on 4/26/23.
//

import SwiftUI

struct POI_InfoView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Group{
                VStack(alignment: .leading){
                    Text("Business Name")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Business Type")
                        .font(.title2)
                        .padding(.bottom)
                    
                    Text("Address: " + "10th street")
                        .font(.body)
                    Text("Hours: " + "8 am to 9 pm")
                        .font(.body)
                    Text("Phone Number: " + "656-965-2396")
                        .font(.body)
                    Text("Website: " + "https://www.como.gov/")
                        .font(.body)
                        .padding(.bottom)
                    
                    Text("Rating: " + "3.8 out of 5 stars")
                        .font(.body)
                    Text("Review 1: 4.5/5")
                        .font(.body)
                        .padding(.bottom)
                    Text("The food here was great. Would recommend bringing family.")
                        .padding(.bottom)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }.padding(/*@START_MENU_TOKEN@*/[.top, .bottom, .trailing]/*@END_MENU_TOKEN@*/)
                VStack(alignment: .leading) {
                    Text("Review 2: 2/5")
                        .font(.body)
                        .padding(.bottom)
                    Text("Service was slow and waiters were rude. Not worth the price")
                        .padding(.bottom)
                    Text("Review 3: 3/5")
                        .font(.body)
                        .padding(.bottom)
                    Text("Good food for a sunny day.")
                        .padding(.bottom)
                    Text("More reviews on Yelp")
                        .foregroundColor(Color.blue)
                     
                }
            }
            Spacer()

        }
        .padding(/*@START_MENU_TOKEN@*/[.top, .bottom, .trailing]/*@END_MENU_TOKEN@*/)
        
    }
}

struct POI_InfoView_Previews: PreviewProvider {
    static var previews: some View {
        POI_InfoView()
    }
}
