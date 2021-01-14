//
//  Song+CoreDataProperties.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//
//

import Foundation
import CoreData


extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var artist: String?
    @NSManaged public var audioUrlData: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var imageUrlData: Data?
    @NSManaged public var name: String?
    @NSManaged public var album: String?
    @NSManaged public var filename: String?
    @NSManaged public var playlistOrderDict: NSDictionary?
    @NSManaged public var playlists: NSSet?
    
    public var playlistsArray: [Playlist] {
        let set = playlists as? Set<Playlist> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    
    // convert NSDictionary to swift Dictionary
    public var orderDict: Dictionary<String, Int> {
        if let dict = playlistOrderDict {
            let returnDict = dict as! Dictionary<String, Int>
            return returnDict
        } else {
            return [String: Int]()
        }

    }
    
    // wrapped optional attributes
    public var wrappedName: String {
        name ?? "Deleted"
    }
    
    public var wrappedArtist: String {
        artist ?? "Unknown Artist"
    }
    
    public var wrappedAlbum: String {
        album ?? "Unknown Album"
    }
    
    public var wrappedFilename: String {
        filename ?? "Unknown Filename"
    }
    
    public var wrappedAudioUrl: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var url: URL = paths[0]
        do {
            if let data = audioUrlData {
                var stale = true
                url = try URL.init(resolvingBookmarkData: data, bookmarkDataIsStale: &stale)
            }
        } catch {
            print("Error getting url")
        }
        
        return url
    }
    
    public var wrappedImageUrl: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var url: URL = paths[0]
        do {
            if let data = imageUrlData {
                var stale = false
                url = try URL.init(resolvingBookmarkData: data, bookmarkDataIsStale: &stale)
            }
        } catch {
            print("Error getting url")
        }

        return url
    }
}

// MARK: Generated accessors for playlists
extension Song {

    @objc(addPlaylistsObject:)
    @NSManaged public func addToPlaylists(_ value: Playlist)

    @objc(removePlaylistsObject:)
    @NSManaged public func removeFromPlaylists(_ value: Playlist)

    @objc(addPlaylists:)
    @NSManaged public func addToPlaylists(_ values: NSSet)

    @objc(removePlaylists:)
    @NSManaged public func removeFromPlaylists(_ values: NSSet)

}

extension Song : Identifiable {

}

