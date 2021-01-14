//
//  iPod_appApp.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import AVKit
import MediaPlayer

@main
struct iPod_appApp: App {
    let persistenceController = PersistenceController.shared
    let player = MyAudioPlayer()
    let audioSession = AVAudioSession.sharedInstance()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(player)
                .onAppear( perform: {
                    do {
                        // Set the audio session category, mode, and options.
                        try audioSession.setCategory(.playback,  options: [])
                    } catch {
                        print("Failed to set audio session category.")
                    }
                    player.setupRemoteTransportControls()
                })
        }
    }
}
