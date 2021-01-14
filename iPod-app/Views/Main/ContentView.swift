//
//  ContentView.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-14.
//

import SwiftUI
import CoreData

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        MainMenuView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
