//
//  RatingStar.swift
//  CityAssistant
//
//  Created by Jules Maslak on 6/23/23.
//

import Foundation
import SwiftUI

public struct RatingStars: View {
    var rating: Decimal

    public var body: some View {
        ZStack {
            BackgroundStars()
            ForegroundStars(rating: rating)
        }
    }
}

private struct ForegroundStars: View {
    var rating: Decimal

    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                RatingStar(
                    rating: self.rating,
                    color: .red,
                    index: index
                )
            }
        }
    }
}

private struct BackgroundStars: View {
    var body: some View {
        HStack {
            ForEach(0..<5) { _ in
                Image(systemName: "star.fill")
            }
        }.foregroundColor(.gray)
    }
}

struct RatingStar: View {
    var rating: CGFloat
    var color: Color
    var index: Int
    
    
    var maskRatio: CGFloat {
        let mask = rating - CGFloat(index)
        
        switch mask {
        case 1...: return 1
        case ..<0: return 0
        default: return mask
        }
    }


    init(rating: Decimal, color: Color, index: Int) {
        self.rating = CGFloat(Double(rating.description) ?? 0)
        self.color = color
        self.index = index
    }


    var body: some View {
        GeometryReader { star in
            Image(systemName: "star.fill")
                .foregroundColor(self.color)
                .mask(
                    Rectangle()
                        .size(
                            width: star.size.width * self.maskRatio,
                            height: star.size.height
                        )
                    
                )
        }
    }
}
