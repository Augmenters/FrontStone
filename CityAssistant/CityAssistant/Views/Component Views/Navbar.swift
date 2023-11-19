//
//  Navbar.swift
//  CityAssistant
//
//  Created by Jules Maslak on 11/19/23.
//

import Foundation
import SwiftUI

private let buttonSize: CGFloat = 40

struct NavBar: View
{
    @Binding public var selectedView: ViewType
    
    init(selectedView: Binding<ViewType>) {
        self._selectedView = selectedView
    }
    
    var body: some View
    {
        ZStack()
        {
            VStack()
            {
                Divider().frame(height:5)
                         .overlay(.gray)
                         .offset(y: -20)
                HStack()
                {
                    Button
                    {
                        selectedView = ViewType.CrimeView
                    }
                    label:
                    {
                        if(selectedView == ViewType.CrimeView)
                        {
                            Image(systemName: "map.fill")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                        else
                        {
                            Image(systemName: "map")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                    }.padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                    Button
                    {
                        selectedView = ViewType.POIView
                    }
                    label:
                    {
                        if(selectedView == ViewType.POIView)
                        {
                            Image(systemName: "safari.fill")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                        else
                        {
                            Image(systemName: "safari")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                    }.padding(.init(top: 0, leading: 50, bottom: 0, trailing: 50))
                    Button
                    {
                        selectedView = ViewType.AboutView
                    }
                    label:
                    {
                        if(selectedView == ViewType.AboutView)
                        {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                        else
                        {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                    }.padding(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                }.offset(y:-15)
            }
        }.frame(height: 70)
    }
}
