//
//  ImageTest.swift
//  CityAssistant
//
//  Created by Erika Zhou on 9/17/23.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        Image("cat-app-icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
