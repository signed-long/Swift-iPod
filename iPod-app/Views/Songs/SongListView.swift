//
//  SongListView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import CoreData

// MARK: SongListView
//
// A view with a list of all the user's songs.
struct SongListView: View {
    @Environment(\.managedObjectContext) private var moc
    @EnvironmentObject var player: MyAudioPlayer
    @State var showEditSongSheet: Bool = false
    @State var songs: [Song]
    @State var songToEdit: Int = 0
    var navigationTitle: String
    var playlist: Playlist?
//    @State var showImage = true
            
    var body: some View {

        List{
            if let playlist = playlist {
                if playlist.type != "artist" {
                    Image(uiImage: getImage(url: playlist.wrappedImageUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 10)
                        .contextMenu {
                            Button(action: {
                                self.songToEdit = -1
                                showEditSongSheet.toggle()
                            }) {
                                Text("Change \(playlist.type!) artwork")
                                Image(systemName: "art")
                            }
                        }
                }
            }
            if !songs.isEmpty {
                ForEach(Array(zip(songs, 0...songs.count-1)), id: \.self.0)
                    { (song, index) in
                    Button( action: {
                        player.setUp(songs: songs, index: index)
                    }) {
                        SongCellView(song: song, imageUrl: song.wrappedImageUrl, showImage: showImage(), trackNum: "\(index + 1)")
                    }
                    .disabled(!checkSongUrlIsReachable(url: song.wrappedAudioUrl))
                    .contextMenu {
                        Button(action: {
                            print(song)
                            self.songToEdit = index
                            showEditSongSheet.toggle()
                        }) {
                            Text("Change song artwork")
                            Image(systemName: "art")
                        }
                    }
                }
                .onDelete(perform: deleteSong)
                .onMove(perform: move)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarItems(
            trailing:
                Button(action: { player.setUp(songs: songs.shuffled()) }) {
                    Image(systemName: "shuffle").imageScale(.large)
                }
                .disabled(songs.isEmpty)
        )

        .fileImporter(
            isPresented: $showEditSongSheet,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            do {
                let url = try result.get()[0]
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                if didStartAccessing {
                    if songToEdit != -1 {
                        songs[songToEdit].imageUrlData = try url.bookmarkData()
                    } else if playlist!.type == "album" {
                        playlist!.imageUrlData = try url.bookmarkData()
                        for song in playlist!.songsArray {
                            song.imageUrlData = try url.bookmarkData()
                        }
                    } else if playlist!.type == "playlist" {
                        playlist!.imageUrlData = try url.bookmarkData()
                    }
                    url.stopAccessingSecurityScopedResource()
                    try moc.save()
                    
                } else {
                    throw ImportError.runtimeError("Could not access url")
                }

            } catch {
                print(error)
            }
            
        }
    }
    
    func showImage() -> Bool {
        if let playlist = playlist {
            return !(playlist.type == "playlist" || playlist.type == "album")
        }
        
        return true
    }
    
    // MARK: deleteSong
    //
    // Deletes a song from the db, and from all playlists with that song in it
    //
    // - Parameter offsets: IndexSet of indecies in the List that should be deleted,
    //   automatically passed in by .onDelete().
    func deleteSong(offsets: IndexSet) {
        if let playlist = playlist {
            for index in offsets {
                let song = songs[index]
                playlist.removeSong(song: song)
                do {
                    try moc.save()
                } catch {
                    print("Error deleting song")
                    print(error.localizedDescription)
                }
            }
            
        } else {
            for index in offsets {
                let song = self.songs[index]
                let playlists = song.playlistsArray
                for playlist in playlists {
                    playlist.removeSong(song: song)
                }
                do {
                    moc.delete(song)
                    try moc.save()
                } catch {
                    print("Error deleting song")
                    print(error.localizedDescription)
                }
            }
        }
        
        for index in offsets {
            songs.remove(at: index)
        }
    }
    
    // MARK: move
    //
    // Reorders the playlist.
    //
    // - Parameter
    func move(from source: IndexSet, to destination: Int) {
        songs.move(fromOffsets: source, toOffset: destination)

        if let playlist = playlist {
            var counter = 0
            for song in songs {
                var dict = song.orderDict
                if dict[playlist.wrappedUuidString] != counter {
                    dict.updateValue(counter, forKey: playlist.wrappedUuidString)
                    song.playlistOrderDict = dict as NSDictionary
                }
                counter += 1
            }
            do {
                try moc.save()
            } catch {
                print("error saving order")
                print(error.localizedDescription)
            }
        }
    }
}

