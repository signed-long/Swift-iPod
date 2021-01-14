//
//  Playlist+CoreDataProperties.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//
//

import Foundation
import CoreData

extension Playlist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageUrlData: Data?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var songs: NSSet?
    
    // get songs of playlist sorted by each song's index stored
    // in it's orderDict attribute at key self.wrappedUuidString
    public var songsArray: [Song] {
        let set = songs as? Set<Song> ?? []
        return set.sorted {
            $0.orderDict[self.wrappedUuidString]! < $1.orderDict[self.wrappedUuidString]!
        }
    }
    
    // wrapped optional attributes
    public var wrappedName: String {
        return name ?? "Unknown Name"
    }
    
    public var wrappedUuidString: String {
        if let id = self.id {
            return id.uuidString
        }
        return "No ID"
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
    
    func removeSong(song: Song) {
        var dict = song.orderDict
        dict.removeValue(forKey: self.wrappedUuidString)
        song.playlistOrderDict = dict as NSDictionary
        self.removeFromSongs(song)
    }
    
    // get songs of playlist sorted by each song's index stored
    // in it's orderDict attribute at key self.wrappedUuidString
    func getSongs(orderdBy: String) -> [Song] {
        let set = songs as? Set<Song> ?? []
        if orderdBy == "playlist" {
            return set.sorted {
                $0.orderDict[self.wrappedUuidString]! < $1.orderDict[self.wrappedUuidString]!
            }
        } else {
            return set.sorted {
                $0.wrappedFilename < $1.wrappedFilename
            }
        }
    }
}

// MARK: Generated accessors for songs
extension Playlist {

    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: Song)

    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: Song)

    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)

    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)

}

