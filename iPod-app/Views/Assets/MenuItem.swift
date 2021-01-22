//
//  MenuItem.swift
//  iPod-app
//
//  Created by Michael Long on 2021-01-22.
//

import SwiftUI
import Foundation

// MARK: MenuItem
//
// A view for menu item navigation links.
struct MenuItem: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var action: Int?
    let tag: Int
    let destination: AnyView
    let systemName: String
    let text: String
    
    var body: some View {
        NavigationLink(destination: destination, tag: tag, selection: $action) {
            EmptyView()
        }
        
        Divider()
        Button(action: {self.action = tag}) {
                HStack {
                    Image(systemName: systemName)
                    Text(text)
                        .font(.title2)
                        .padding(.horizontal, 2)
                    Spacer()
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.leading, 12)

        }
        Divider()
    }
}
