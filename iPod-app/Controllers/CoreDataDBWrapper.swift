//
//  CoreDataDBWrapper.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import CoreData
import Foundation
import CoreServices
import AVKit

// MARK: CoreDataDBWrapper
//
// A wrapper class to abstract details of adding songs and Playlists to DB.
class CoreDataDBWrapper {
    private var moc: NSManagedObjectContext

    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    // MARK: storeSong
    //
    // Stores a song's information in db.
    //
    // - Parameters:
    //   - url: URL that the song is at.
    //   - playlist: The playlist the song will be a part of.
    //   - pos: The position of the song in the playlist.
    // - Throws: abunch of trys in there.
    private func storeSong(url: URL, playlist: Playlist? = nil, pos: Int = 0) throws -> Song  {
        
        // create a new song
        let newSong = Song(context: self.moc)
        newSong.id = UUID()
        newSong.filename = url.lastPathComponent
        
        // access security scoped url
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        if didStartAccessing {
            
            // save audio url bookmark
            newSong.audioUrlData = try url.bookmarkData()
            
            // get song's metadata
            let asset = AVAsset(url: url)
            let md = asset.metadata
            
            if md.isEmpty {
                newSong.name = url.deletingPathExtension().lastPathComponent
            }
            
            for item in md {

                guard let key = item.commonKey?.rawValue, let value = item.value as? String else{
                    continue
                }
                switch key {
                    case "title" : newSong.name = value
                    case "artist": newSong.artist = value
                    case "albumName": newSong.album = value
                    default:
                        continue
               }
            }
            
            if let playlist = playlist {
                var dict = newSong.orderDict
                dict.updateValue(0, forKey: playlist.wrappedUuidString)
                newSong.playlistOrderDict = dict as NSDictionary
                playlist.addToSongs(newSong)
                newSong.addToPlaylists(playlist)
            }
            
            url.stopAccessingSecurityScopedResource()
            
        } else {
            throw ImportError.runtimeError("Could not access url")
        }
        
        try self.moc.save()
        return newSong
    }
    
    
    private func addSongToCollections(song: Song) {
        if song.album != nil {
            let predicate = NSPredicate(format: "name == %@ AND type == %@", song.wrappedAlbum, "album")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 1
            let results = try! self.moc.fetch(fetchRequest)
            let playlist: Playlist
            
            if results.isEmpty {
                // create a new playlist
                playlist = Playlist(context: self.moc)
                
                // set playlist attributes
                playlist.name = song.wrappedAlbum
                playlist.id = UUID()
                playlist.type = "album"
                
            } else {
                playlist = results[0] as! Playlist
            }
                        
            playlist.addToSongs(song)
            song.addToPlaylists(playlist)
            
            var dict = song.orderDict
            dict.updateValue(0, forKey: playlist.wrappedUuidString)
            song.playlistOrderDict = dict as NSDictionary
            
            try! self.moc.save()
        }
        if song.artist != nil {
            let predicate = NSPredicate(format: "name == %@ AND type == %@", song.wrappedArtist, "artist")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
            fetchRequest.predicate = predicate
            let results = try! self.moc.fetch(fetchRequest)
            let playlist: Playlist
            
            if results.isEmpty {
                // create a new playlist
                playlist = Playlist(context: self.moc)
                
                // set playlist attributes
                playlist.name = song.wrappedArtist
                playlist.id = UUID()
                playlist.type = "artist"
                
            } else {
                playlist = results[0] as! Playlist
            }
            
            playlist.addToSongs(song)
            song.addToPlaylists(playlist)
            
            var dict = song.orderDict
            dict.updateValue(0, forKey: playlist.wrappedUuidString)
            song.playlistOrderDict = dict as NSDictionary
            
            try! self.moc.save()
        }
    }

    // MARK: importAsSongs
    //
    // Given a result from a fileImporter stores songs in DB.
    //
    // - Parameter results: A Result<[URL], Error> from the fileImporter.
    // - Throws: abunch of trys in there.
    func importAsSongs(results: Result<[URL], Error> ) throws -> Void {
            
        for url in try results.get() {
            var sameSongs = getSameSongs(url: url)
            // only add the new song if it's not already added
            if sameSongs.isEmpty {
                let song = try storeSong(url: url)
                addSongToCollections(song: song)
                
            } else {
                addSongToCollections(song: sameSongs[0] as! Song)
            }
        }
    }
    
    // MARK: importAsPlaylist
    //
    // Given a result from a fileImporter stores songs in DB in a Playlist.
    //
    // - Parameters:
    //   - results: A Result<[URL], Error> from the fileImporter.
    //   - name: The name fo the Playlist.
    // - Returns: A Playlist object.
    // - Throws: abunch of trys in there.
    func importAsPlaylist(results: Result<[URL], Error>, name: String) throws -> Playlist {
        
        // create a new playlist
        let newPlaylist: Playlist = Playlist(context: self.moc)
        
        // set playlist attributes
        newPlaylist.name = name
        newPlaylist.id = UUID()
        newPlaylist.type = "playlist"
        
        var counter = 0
        
        // add a song for every url in the result
        for url in try results.get() {
            
            let sameSongs = getSameSongs(url: url)
            let songToAdd: Song
            
            // check if the same song is already stored
            if sameSongs.isEmpty {
                let song = try storeSong(url: url, playlist: newPlaylist, pos: counter)
                addSongToCollections(song: song)

            } else {
                // just add existing song to playlist
                songToAdd = sameSongs[0] as! Song
                addSongToCollections(song: songToAdd)
                songToAdd.playlistOrderDict = [newPlaylist.wrappedUuidString: counter]
                newPlaylist.addToSongs(songToAdd)
                songToAdd.addToPlaylists(newPlaylist)
            }
            counter += 1
        }
        
        try self.moc.save()
    
        return newPlaylist
    }
    
    // MARK: storePlaylistImage
    //
    // Given the URL a song will be added to the db.
    //
    // - Parameters:
    //   - playlist: The Playlist to add an image to.
    //   - results: Result<[URL], Error> from the fileImporter.
    // - Throws: abunch of trys in there.
    func storePlaylistImage(playlist: Playlist, results: Result<[URL], Error>, album: Bool = false) throws -> Void {
        
        if let url: URL = try results.get().first {
            
            // store bookmark to image file in song
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            
            if didStartAccessing {
                playlist.imageUrlData = try url.bookmarkData()
                url.stopAccessingSecurityScopedResource()
            } else {
                throw ImportError.runtimeError("Could not access url")
            }
            
        } else {
            throw ImportError.runtimeError("Could not access url")
            
        }
        try self.moc.save()
    }
    
    // MARK: getSameSongs
    //
    // Given a URL will query the db and return an array of existing songs with the same filenames.
    //
    // - Parameter url: The url to check.
    // - Returns: an array of song objects.
    private func getSameSongs(url: URL) -> [Any] {
        
        // fetch results
        let predicate = NSPredicate(format: "filename == %@", url.lastPathComponent)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
        fetchRequest.predicate = predicate
        let results = try! self.moc.fetch(fetchRequest)
        
        return results
    }
}
