//
//  NowPlayingView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: NowPlayingView
//
// This view appears in a sheet triggerd by the NowPlayingButtonView, it displays name of current song,
// and has controlls for play/pause and skip forward/backward.
struct NowPlayingView: View {
    @EnvironmentObject var player: MyAudioPlayer
    let screenSize: CGFloat = UIScreen.main.bounds.width - 50

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                
                if let song = player.currentSong {
                    Image(uiImage: getImage(url: song.wrappedImageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 10)
                        .padding()
                } else {
                    Image(systemName: "hifispeaker.fill")
                        .resizable()
                        .frame(width: 400, height: 400,  alignment: .center)
                        .padding()
                        .cornerRadius(20)
                        .shadow(radius: 12)
                }

                VStack {
                    if let song = player.currentSong {
                        let stringWidth = song.wrappedName.widthOfString(usingFont : .title)
                        
                        if stringWidth >= screenSize {
                            MarqueeText(
                                text: song.wrappedName,
                                font: .title,
                                leftFade: 5,
                                rightFade: 5,
                                startDelay: 3
                            )
                        } else {
                            Text(song.wrappedName)
                                .font(.title)
                                .bold()
                        }
                    } else {
                        Text("Not Playing")
                            .font(.title)
                            .bold()
                    }
                    
                    Text(player.currentSong != nil ? player.currentSong!.wrappedArtist : "")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                        .padding(.bottom, 1)
                    Text(player.currentSong != nil ? player.currentSong!.wrappedAlbum : "")
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                HStack(spacing: 32) {
                    Button(action: { player.skipToPrev() }) {
                        ZStack {
                            Circle()
                                .frame(width: 80, height: 80)
                                .accentColor(.pink)
                                .shadow(radius: 10)
                            Image(systemName: "backward.fill")
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }

                    Button(action: { player.playPause() }) {
                        ZStack {
                            Circle()
                                .frame(width: 80, height: 80)
                                .accentColor(.pink)
                                .shadow(radius: 10)
                            Image(systemName: player.isPlaying  ? "pause.fill" : "play.fill").imageScale(.large)
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }

                    Button(action: { player.skipToNext() }) {
                        ZStack {
                            Circle()
                                .frame(width: 80, height: 80)
                                .accentColor(.pink)
                                .shadow(radius: 10)
                            Image(systemName: "forward.fill")
                                .foregroundColor(.white)
                                .font(.system(.title))
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }
}
