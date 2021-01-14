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
                                NavigationLink(destination: AllSongsView(), tag: 1, selection: $action) {
                                    EmptyView()
                                }
                                NavigationLink(destination: AllPlaylistsView(type: "playlist", moc: self.moc), tag: 2, selection: $action) {
                                    EmptyView()
                                }
                                NavigationLink(destination: AllPlaylistsView(type: "album", moc: self.moc), tag: 3, selection: $action) {
                                    EmptyView()
                                }
                                NavigationLink(destination: AllPlaylistsView(type: "artist", moc: self.moc), tag: 4, selection: $action) {
                                    EmptyView()
                                }
                            }
                            Group {
                                Divider()
                                Button(action: {self.action = 1}) {
                                        HStack {
                                            Image(systemName: "music.quarternote.3")
                                            Text("All songs")
                                                .font(.title2)
                                                .padding(.horizontal, 2)
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        .padding(.leading, 12)

                                }
                                Divider()
                                Button(action: {self.action = 2}) {
                                        HStack {
                                            Image(systemName: "music.note.list")
                                            Text("Playlists")
                                                .font(.title2)
                                                .padding(.horizontal, 2)
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        .padding(.leading, 12)

                                }
                                Divider()
                                Button(action: {self.action = 3}) {
                                        HStack {
                                            Image(systemName: "square.stack")

                                            Text("Albums")
                                                .font(.title2)
                                                .padding(.horizontal, 2)
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        .padding(.leading, 12)

                                }
                                Divider()
                                Button(action: {self.action = 4}) {
                                        HStack {
                                            Image(systemName: "music.mic")
                                            Text("Artists")
                                                .font(.title2)
                                                .padding(.horizontal, 2)
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        .padding(.leading, 12)

                                    }
                                Divider()
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
