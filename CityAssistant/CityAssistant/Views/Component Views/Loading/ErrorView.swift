//
//  ErrorView.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/19/23.
//

import Foundation
import SwiftUI

struct ErrorView : View {
    let error: Any
    let retryHandler: (() -> Void)
    
    var body: some View {
        Text("Encountered an error")
        Button{
            retryHandler()
        }
        label:
        {
            Text("retry")
        }
    }
}

struct ErrorView_Preview : PreviewProvider {
    static var ignored: () -> Void = {  }
    
    static var previews: some View {
        ErrorView(error: "", retryHandler: ignored)
    }
}
