//
//  PlaylistView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI

// MARK: PlaylistView
//
// A view with a list of all the user's playlists
//
// - Parameter playlist: a playlist to display.
struct PlaylistView: View {
    @Environment(\.managedObjectContext) private var moc
    var playlist: Playlist
    var type: String
    
    var body: some View {
        VStack {
            SongListView(songs: playlist.getSongs(orderdBy: self.type), navigationTitle: playlist.wrappedName, playlist: playlist)
                .navigationBarItems(trailing: EditButton())
        }
    }
}
