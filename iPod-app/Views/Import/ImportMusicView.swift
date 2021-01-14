//
//  ImportMusicView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import CoreData

// MARK: ImportMusicView
// The ImportMusicView screen gives a list of options on how the user can import their music.
//
// - Parameter (Binding) showImportMusicSheet: Bool as to whether this view is shown on a sheet.
struct ImportMusicView: View {
    @Binding var showImportMusicSheet: Bool
    @Environment(\.managedObjectContext) var moc
    @State private var isImporting: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                AddMusicOptionCard(imageName: "album", optionText: "as Songs",
                                   colorGradient: [.red, .blue])
                    .simultaneousGesture(TapGesture().onEnded{
                        isImporting.toggle()
                    })
                NavigationLink(destination: ImportAsMixtapeView(showImportMusicSheet: $showImportMusicSheet)) {
                    AddMusicOptionCard(imageName: "mixtape", optionText: "as Playlist", colorGradient: [.blue, .red])
                }
            }
            .navigationTitle("Import Music")
        }
        .padding(0)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { result in
            do {
                try CoreDataDBWrapper(moc: moc).importAsSongs(results: result)
                showImportMusicSheet.toggle()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
