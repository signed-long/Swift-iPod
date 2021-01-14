//
//  utils.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import Foundation
import CoreData
import MediaPlayer

// MARK: getImage
//
// Gets a UIImage from a url.
//
// - Parameter url: the url of an image file.
func getImage(url: URL) -> UIImage {
    // returns a UIImage to display as cover art in PlayerView
    
    do {
        let startAccessing = url.startAccessingSecurityScopedResource()
        if startAccessing {
            let imageData = try Data(contentsOf: url)
            
            if let image = UIImage(data: imageData) {
                url.stopAccessingSecurityScopedResource()
                return image
            } else {
                url.stopAccessingSecurityScopedResource()
                throw ImportError.runtimeError("Could not access url")
            }
        }
    } catch {
        print(error)
    }
    return UIImage(named: "pink-floyd-wish-you-were-here")!
}

// MARK: checkSongUrlIsReachable
//
// Checks if the file at a url is reachable.
//
// - Parameter url: the url to check.
func checkSongUrlIsReachable(url: URL) -> Bool {
    do {
        if !url.startAccessingSecurityScopedResource() {
            return false
        }
        
        if url == FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] {
            return false
        }
        
        var isGoodUrl: Bool
        isGoodUrl = try url.checkResourceIsReachable()
        url.stopAccessingSecurityScopedResource()
        return isGoodUrl
        
    } catch {
        print(error)
        return false
    }
}

// MARK: dropDB
//
// Deletes everything in the db.
func dropDB(moc: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
    
    // Configure Fetch Request
    fetchRequest.includesPropertyValues = false

    do {
        let items = try moc.fetch(fetchRequest) as! [NSManagedObject]

        for item in items {
            moc.delete(item)
        }

        // Save Changes
        try moc.save()

    } catch {
        print("error dropping db")
    }
    
    let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
    
    // Configure Fetch Request
    fetchRequest2.includesPropertyValues = false

    do {
        let items = try moc.fetch(fetchRequest2) as! [NSManagedObject]

        for item in items {
            moc.delete(item)
        }

        // Save Changes
        try moc.save()

    } catch {
        print("error dropping db")
    }
}

// MARK: ImportError
//
// A custome error that may be thrown by this class' methods
enum ImportError: Error {
    case runtimeError(String)
}


