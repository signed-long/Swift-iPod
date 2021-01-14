//
//  AllSongsView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: AllSongsView
//
// A view with a list of all the user's songs.
struct AllSongsView: View {
    @EnvironmentObject var player: MyAudioPlayer
    @FetchRequest(
        entity: Song.entity(),
        sortDescriptors: [NSSortDescriptor(key: "artist", ascending: true), NSSortDescriptor(key: "name", ascending: true)],
        animation: .default)
    private var songs: FetchedResults<Song>
    
    var body: some View {
        SongListView(songs: songs.suffix(songs.count), navigationTitle: "All Songs")
    }
}
