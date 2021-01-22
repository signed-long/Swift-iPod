//
//  MainMenuView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import CoreData

// MARK: MainMenuView
//
// A view with the main navigation menu of the app.
struct MainMenuView: View {
    @EnvironmentObject var player: MyAudioPlayer
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var moc
    @State private var showImportMusicSheet: Bool = false
    @State private var showingNowPlayingSheet: Bool = false
    @State private var action: Int? = 0
    
    @FetchRequest(
        entity: Playlist.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "type != %@", "artist"),
        animation: .default)
    private var playlists: FetchedResults<Playlist>
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
                NavigationView {
                    ScrollView {
                        VStack {

                            Group {
                                MenuItem(action: $action,
                                         tag: 1,
                                         destination: AnyView(AllSongsView()),
                                         systemName: "music.quarternote.3",
                                         text: "All songs")
                                MenuItem(action: $action,
                                         tag: 2,
                                         destination: AnyView(AllPlaylistsView(type: "playlist", moc: self.moc)),
                                         systemName: "music.note.list",
                                         text: "Playlists")
                                MenuItem(action: $action,
                                         tag: 3,
                                         destination: AnyView(AllPlaylistsView(type: "album", moc: self.moc)),
                                         systemName: "square.stack",
                                         text: "Albums")
                                MenuItem(action: $action,
                                         tag: 4,
                                         destination: AnyView(AllPlaylistsView(type: "artist", moc: self.moc)),
                                         systemName: "music.mic",
                                         text: "Artists")
                            }

                            LazyVGrid(columns: layout) {
                                ForEach(playlists, id: \.id) { playlist in
                                    NavigationLink(destination: PlaylistView(playlist: playlist, type: playlist.type ?? "playlist")) {
                                        VStack {
                                            Image(uiImage: getImage(url: playlist.wrappedImageUrl))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                            HStack {
                                                Text(playlist.wrappedName)
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                        }
                                        .padding(10)
                                    }
                                }
                            }
                        }
                        .navigationTitle("Music")
                        .navigationBarItems(
                            trailing:
                                Button(action: { showImportMusicSheet.toggle() }) {
                                    Image(systemName: "folder.badge.plus").imageScale(.large)
                                }
                                .sheet(isPresented: self.$showImportMusicSheet) {
                                    ImportMusicView(showImportMusicSheet: self.$showImportMusicSheet)
                                }
                        )
                }
            }

            NowPlayingButtonView(showingNowPlayingSheet: $showingNowPlayingSheet)
                .sheet(isPresented: self.$showingNowPlayingSheet) {
                    NowPlayingView().environmentObject(player)
                }
        }
    }
}
