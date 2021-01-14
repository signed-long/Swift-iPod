//
//  NowPlayingButtonView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: NowPlayingButtonView
//
// This View is the button that always stays at the bottom of the screen, displaying the current song's
// name and a play/pause button. Touching this button opens NowPlayingView in a sheet.
//
// - Parameter (Binding) showingNowPlayingSheet: Bool as to whether the NowPlayingView is shown on a sheet.
struct NowPlayingButtonView: View {
    @Binding var showingNowPlayingSheet: Bool
    @EnvironmentObject var player: MyAudioPlayer

    var body: some View {
        HStack {
            Button(action: {self.showingNowPlayingSheet.toggle()}) {
                HStack() {
                    if let song = player.currentSong {
                        Text(song.wrappedName)
                            .lineLimit(1)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Not Playing")
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    Button(action: { player.playPause() }) {
                        Image(systemName: player.isPlaying  ? "pause.fill" : "play.fill").imageScale(.large)
                    }
                        .padding()
               }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .foregroundColor(Color.white)
           }
        }
    }
}
