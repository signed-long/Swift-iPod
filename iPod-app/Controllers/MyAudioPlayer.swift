//
//  MyAudioPlayer.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import Foundation
import AVKit
import CoreData
import SwiftUI
import Combine
import MediaPlayer

// MARK: MyAudioPlayer
//
// An audio player class that supports skipping forward and backwards through songs.
//
// TODO: Implement playerItemArray as a linked list to remove costly deletions from first element of array.
class MyAudioPlayer: ObservableObject {
    private let padding = 3
    private var player = AVPlayer()
    private var playerItemArray = [AVPlayerItem]()
    private var songUrlArray = [Song]()
    private var currentPlayerItemIndex = -1
    private var currentUrlIndex = -1
    private var currentPlayerItem: AVPlayerItem?
    @Published var isPlaying = false
    @Published var currentSong: Song? = nil {
        didSet {
            var nowPlayingInfo = [String : Any]()
            if let song = currentSong {
                nowPlayingInfo[MPMediaItemPropertyTitle] = song.wrappedName
            } else {
                nowPlayingInfo[MPMediaItemPropertyTitle] = "Not Playing"
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(songDidEnd), name:
        NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // MARK: setUp
    //
    // Given a FetchedResults<Song> the songUrlArray and playerItemArray are built,
    // the current song is loaded in the player and played.
    //
    // - Parameters:
    //   - songs: FetchedResults<Song> the song objects to make the arrays out of.
    //   - currentUrlIndex: The index of the song to be played first.
    public func setUp(songs: [Song], index: Int = 0) {
        currentUrlIndex = index
        playerItemArray = [AVPlayerItem]()
        songUrlArray = songs

        buildPlayerItemArray()
        loadPlayer(item: currentPlayerItem!, forward: true)
        play()
    }
    
    // MARK: playPause
    //
    // Toggles whether a song is playing or not.
    public func playPause() {
        if currentPlayerItem != nil {
            if isPlaying {
                pause()
            } else {
                play()
            }
        }
    }
    
    // MARK: skipToNext
    //
    // Skips to the next song.
    public func skipToNext() {
        if currentUrlIndex != -1 && currentUrlIndex != songUrlArray.count - 1 {
            updatePlayerItemArray(forward: true)
            if checkSongUrlIsReachable(url: songUrlArray[currentUrlIndex].wrappedAudioUrl) {
                if playerItemArray[currentPlayerItemIndex] != player.currentItem {
                    stop()
                    loadPlayer(item: playerItemArray[currentPlayerItemIndex], forward: true)
                    play()
                } else if currentUrlIndex < songUrlArray.count - 1 {
                    skipToNext()
                }
            } else {
                skipToNext()
            }
        } else {
            print("No more songs")
        }
    }
    
    // MARK: skipToPrev
    //
    // Skips to the previous song.
    public func skipToPrev() {
        if currentUrlIndex != -1 && currentUrlIndex != 0 {
            updatePlayerItemArray(forward: false)
            if checkSongUrlIsReachable(url: songUrlArray[currentUrlIndex].wrappedAudioUrl) {
                if playerItemArray[currentPlayerItemIndex] != player.currentItem {
                    stop()
                    loadPlayer(item: playerItemArray[currentPlayerItemIndex], forward: false)
                    play()
                } else if currentUrlIndex > 0 {
                    skipToPrev()
                }
            } else {
                skipToPrev()
            }
        } else {
            print("No more songs")
        }
    }
    
    // MARK: play
    //
    // Plays the current song.
    private func play() {
        isPlaying = true
        player.play()
    }
    
    // MARK: pause
    //
    // Pauses the current song.
    private func pause() {
        isPlaying = false
        player.pause()
    }
    
    // MARK: stop
    //
    // Rewinds the player item to the start and pauses it.
    private func stop() {
        player.seek(to: CMTime.zero)
        pause()
    }
    
    // MARK: songDidEnd
    //
    // Advances the player to the next song when the current song ends.
    //
    // Parameter notification: NSNotification that triggers this method.
    @objc private func songDidEnd(notification: NSNotification) {
        if currentUrlIndex != songUrlArray.count - 1 {
            skipToNext()
        } else {
            stop()
        }
     }

    // MARK: loadPlayer
    //
    // Given a AVPlayerItem it is loaded into the player, if the player
    // already contians a song it is stopped.
    //
    // Paremeter item: AVPlayerItem to be loaded.
    private func loadPlayer(item: AVPlayerItem, forward: Bool) {
        if player.currentItem != nil {
            stop()
        }
        player.replaceCurrentItem(with: item)
        currentSong = songUrlArray[currentUrlIndex]
    }
    
    // MARK: buildPlayerItemArray
    //
    // Builds an array of AVPlayerItems that as items at most \(padding) places
    // before and after the current song's AVPlayerItem.
    private func buildPlayerItemArray() {
        // calculate the bounds of the playerItemArray
        let lower = getMinAllowedIndex(index: currentUrlIndex, stepsBackwards: padding)
        let upper = getMaxAllowedIndex(index: currentUrlIndex, stepsForwards: padding, max: songUrlArray.count - 1)

        // append all items necessary to first part of playerItemArray
        for i in stride(from: lower, to: currentUrlIndex , by: 1) {
            let playerItem = getPlayerItemFromUrl(songUrl: songUrlArray[i].wrappedAudioUrl)
            playerItemArray.append(playerItem)
        }
        
        // append the current song to playerItemArray
        currentPlayerItemIndex = playerItemArray.count
        currentPlayerItem = getPlayerItemFromUrl(songUrl: songUrlArray[currentUrlIndex].wrappedAudioUrl)
        playerItemArray.append(currentPlayerItem!)

        // append all items necessary to second part of playerItemArray
        for i in stride(from: currentUrlIndex + 1, to: upper + 1, by: 1) {
            let playerItem = getPlayerItemFromUrl(songUrl: songUrlArray[i].wrappedAudioUrl)
            playerItemArray.append(playerItem)
        }
    }
    
    // MARK: updatePlayerItemArray
    //
    // Updates the playerItemArray to to keep at most \(padding) number of playerItems ahead
    // and behind of the current player item.
    //
    // Paremeter forward: Bool as to whether the current song is being incremented forward or backwards.
    private func updatePlayerItemArray(forward: Bool) {
        if forward {
            
            // add any player items to playerItemArray as needed
            if currentUrlIndex + padding < songUrlArray.count - 1 && currentUrlIndex + padding >= playerItemArray.count - 1 {
                playerItemArray.append(getPlayerItemFromUrl(songUrl: songUrlArray[currentUrlIndex + padding + 1].wrappedAudioUrl))
            }
            
            // remove any player items from playerItemArray as needed
            if currentUrlIndex - padding >= 0 {
                playerItemArray.removeFirst(1) // this is expensize
                currentPlayerItemIndex -= 1
            }
            
            // increment current indecies
            currentUrlIndex += 1
            currentPlayerItemIndex += 1
            
        } else {
            
            // remove any player items from playerItemArray as needed
            if currentUrlIndex + padding < songUrlArray.count - 1 && currentUrlIndex + padding >= playerItemArray.count - 1 {
                playerItemArray.removeLast()
            }
            
            // add any player items to playerItemArray as needed
            if currentUrlIndex - padding - 1 >= 0 {
                playerItemArray.insert(getPlayerItemFromUrl(songUrl: songUrlArray[currentUrlIndex - padding - 1].wrappedAudioUrl), at: 0)
                currentPlayerItemIndex += 1
            }
            
            // decrement current indecies
            currentUrlIndex -= 1
            currentPlayerItemIndex -= 1
        }
    }
    
    // MARK: getMinAllowedIndex
    //
    // Gets an inbound index ( >= 0 ) after taking \(stepsBackwards) back.
    //
    // Paremeters:
    // - index: The current index we are stepping back from.
    // - stepsBackwards: At most how many steps we are taking back.
    // Returns Int: an index ( >= 0 ) after taking \(stepsBackwards) back from \(index).
    private func getMinAllowedIndex(index: Int, stepsBackwards: Int) -> Int {
        let dif = index - stepsBackwards
        if dif < 0 {
            return 0
        } else {
            return dif
        }
    }

    // MARK: getMaxAllowedIndex
    //
    // Gets an inbound index ( <= max ) after taking \(stepsForwards) forwards from \(index).
    //
    // Paremeters:
    // - index: The current index we are stepping back from.
    // - stepsForwards: At most how many steps we are taking forward.
    // - max: the maximum allowed value to be returned.
    // Returns Int: an inbound index ( <= max ) after taking \(stepsForwards) forwards from \(index).
    private func getMaxAllowedIndex(index: Int, stepsForwards: Int, max: Int) -> Int {
        let sum = index + stepsForwards
        if sum > max {
            return max
        } else {
            return sum
        }
    }
    
    // MARK: getPlayerItemFromUrl
    //
    // Gets a AVPlayerItem from a URL.
    //
    // Paremeter songUrl: URL to build a AVPlayerItem from.
    // Returns AVPlayerItem: a AVPlayerItem from the URL.
    private func getPlayerItemFromUrl(songUrl: URL) -> AVPlayerItem {
        if !songUrl.startAccessingSecurityScopedResource() {
            print("FAILING")
        }
        let playerItem = AVPlayerItem(url: songUrl)
        songUrl.stopAccessingSecurityScopedResource()
        
        return playerItem
    }
    
    // MARK: getUrlFromPlayerItem
    //
    // Gets the url of the current AVPlayerItem.
    //
    // Parameter playerItem: AVPlayerItem to get a name from.
    // Returns URL: The url of the song in the AVPlayerItem.
    private func getUrlFromPlayerItem(playerItem: AVPlayerItem) -> URL {
         if let url  = (((playerItem.asset) as? AVURLAsset)?.url) {
            return url
         } else {
            return URL.init(string: "No Url")!
        }
    }
    
    // MARK: setupRemoteTransportControls
    //
    // Sets up audio controls on lock screen and control center.
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                pause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Skip Command
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            
            if let item = self.player.currentItem {
                skipToNext()
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            skipToPrev()
            return .success

        }
    }
}
