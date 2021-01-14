//
//  PlaylistCellView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: PlaylistCellView
//
// A view with a list of all the user's songs.
struct PlaylistCellView: View {
    var name: String
    var imageUrl: URL
    
    var body: some View {
        HStack {
            Image(uiImage: getImage(url: imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 60)
                .shadow(radius: 8)
            VStack {
                Text(name)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 60)
        }
    }
}
