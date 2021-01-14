//
//  SongCellView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: SongCellView
//
// A view with a list of all the user's songs.
struct SongCellView: View {
    var song: Song
    @State var imageUrl: URL
    var showImage: Bool = true
    var trackNum: String
    
    var body: some View {
        HStack {
            if showImage {
                Image(uiImage: getImage(url: song.wrappedImageUrl))
                    .resizable()
                    .frame(width: 55, height: 55, alignment: .leading)
                    .shadow(radius: 8)
            } else {
                Text(trackNum)
                    .font(.callout)
                    .frame(width: 15, alignment: .leading)
            }
            VStack {
                Text(song.wrappedName)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(song.wrappedArtist)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
        }
    }
}
