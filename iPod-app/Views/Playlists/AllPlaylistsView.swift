//
//  AllPlaylistsView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import Foundation
import SwiftUI
import CoreData

// MARK: AllPlaylistsView
//
// A view with a list of all the user's playlists
struct AllPlaylistsView: View {
    var fetchRequest: FetchRequest<Playlist>
    var playlists: FetchedResults<Playlist> { fetchRequest.wrappedValue }
    var moc: NSManagedObjectContext
    let type: String
    
    var body: some View {
        List { ForEach(self.playlists, id: \.id)
            { playlist in
            NavigationLink(destination: PlaylistView(playlist: playlist, type: self.type)) {
                    PlaylistCellView(name: playlist.wrappedName, imageUrl: playlist.wrappedImageUrl)
                }
            }
            .onDelete(perform: deletePlaylist)
        }
        .navigationTitle(self.type.capitalized + "s")
        .navigationBarItems(
            trailing:
                Group {
                    if type == "playlist" {
                        Button(action: { print("ADD")}) {
                            Image(systemName: "plus").imageScale(.large)
                        }
                    }
                }
        )
    }
    
    init(type: String, moc: NSManagedObjectContext) {
        self.type = type
        self.moc = moc
        fetchRequest = FetchRequest<Playlist>(
            entity: Playlist.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            predicate: NSPredicate(format: "type == %@", type))
    }
    
    // MARK: deletePlaylist
    //
    // Deletes a Playlist from the db, and from all songs with it as a Playlsit.
    //
    // - Parameter offsets: IndexSet of indecies in the List that should be deleted,
    //   automatically passed in by .onDelete().
    func deletePlaylist(offsets: IndexSet) {
        for index in offsets {
            let playlist = playlists[index]
            
            let songs = playlist.songsArray
            for song in songs {
                song.removeFromPlaylists(playlist)
            }
            do {
                moc.delete(playlist)
                try moc.save()
            } catch {
                print("Error deleting song")
                print(error.localizedDescription)
            }
        }
    }
}
