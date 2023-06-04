//
//  AboutView.swift
//  ARDemo
//
//  Created by Justin Reini on 4/26/23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Text("AR City Tour")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("The Augmenters")
                .font(.title)
                .padding(.bottom)
            Text("This application was developed by Jackson Atkins, Andrew Brain, Jules Maslak, Jeff Morgan, Justin Reini and Erika Zhou as a senior project for Capstone II at the University of Missouri in Columbia")
                .font(.system(size: 18))
            Spacer()
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
