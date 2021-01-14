//
//  EditSongView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import CoreData

// MARK: EditSongView
//
// A form to edit a song's artwotk and name.
//
// - Parameters
//   - (Binding) showEditSongSheet: Bool as to whether this view is showing on a sheet.
//   - song: the song to edit.
struct EditSongView: View {
    @Binding var showEditSongSheet: Bool
    var moc: NSManagedObjectContext
    var song: Song
    @State private var isImporting: Bool = false
    
    var body: some View {
        Form {
            Section {
                Button(action: {
                    isImporting.toggle()
                }) {
                    Text("Select image")
                 }
            }
        }
        .navigationTitle("Change song Artwork")
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            do {
                let url = try result.get()[0]
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                if didStartAccessing {
                    song.imageUrlData = try url.bookmarkData()
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
}
