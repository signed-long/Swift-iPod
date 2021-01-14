//
//  AddMusicOptionCard.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: AddMusicOptionCard
//
// A card view to display the different options fro importing music.
//
// - Parameters:
//   - imageName: The name of the image asset to display as the bg of the card.
//   - optionText: The text on the card.
//   - colorGradient: An array of Color objects to represent the colour gradient of the text on the card.
struct AddMusicOptionCard: View {
    var imageName: String
    var optionText: String
    var colorGradient: [Color]

    var body: some View {
        ZStack {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .cornerRadius(20.0)
                
            LinearGradient(gradient: Gradient(colors: colorGradient),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
                .mask(
                    Text(optionText)
                        .font(Font.system(size:74, design: .monospaced))
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .offset(x:10, y: 0)
        }
     }
}
