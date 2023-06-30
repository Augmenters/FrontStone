//
//  About.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Text("AR City Tour")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Developed by: The Augmenters")
                .font(.title2)
                .padding(.bottom)
            Text("This application was developed by Jackson Atkins, Andrew Brain, Jules Maslak, Jeff Morgan, Justin Reini and Erika Zhou as a senior project for Capstone II at the University of Missouri in Columbia.")
                .font(.system(size: 18))
            Spacer()
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
