//
//  ImportAsMixtapeView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: ImportAsMixtapeView
//
// A form for the user to import a new Playlist/Mixtape.
//
// - Parameter (Binding) showImportMusicSheet: Bool as to whether the main import music sheet is showing.
struct ImportAsMixtapeView: View {
    @Binding var showImportMusicSheet: Bool
    @Environment(\.managedObjectContext) var moc
    @State var tapeTitle: String = ""
    @State var imagePicked: Bool = false
    @State var newPlaylist: Playlist? = nil
    
    // fileImporter settings
    @State var allowedContentTypes: [UTType] = [.audio]
    @State var allowsMultipleSelection: Bool = true
    @State private var isImporting: Bool = false
    
    var body: some View {
        Form {
            Section {
                TextField("Enter Mixtape Name: ", text: $tapeTitle)
            }
            
            Section {
                Button(action: {
                    allowedContentTypes = [.audio]
                    allowsMultipleSelection = true
                    isImporting.toggle()
                }) {
                     Image(systemName: "folder.badge.plus").imageScale(.large)
                 }
            }
            .disabled(tapeTitle.isEmpty || newPlaylist != nil)
            
            Section {
                Button(action: {
                    allowedContentTypes = [.image]
                    allowsMultipleSelection = false
                    isImporting.toggle()
                    
                }) {
                    Text("Add Mixtape Image")
                 }
            }
            .disabled(imagePicked || newPlaylist == nil)
            
            Section {
                Button(action: { showImportMusicSheet.toggle() }) {
                    Text("Add Mixtape")
                }
            }
            .disabled(newPlaylist == nil)
        }
        .navigationTitle("Add a new Mixtape")
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: allowedContentTypes,
            allowsMultipleSelection: allowsMultipleSelection
        ) { result in
            
            if allowedContentTypes == [.audio] {
                do {
                    newPlaylist = try CoreDataDBWrapper(moc: moc).importAsPlaylist(results: result, name: tapeTitle)
                } catch {
                    print(error.localizedDescription)
                }
                
            } else if let playlist = newPlaylist {
                do {
                    try CoreDataDBWrapper(moc: moc).storePlaylistImage(playlist: playlist, results: result)
                    imagePicked = true
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
