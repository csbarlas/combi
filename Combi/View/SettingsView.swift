//
//  SettingsView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/26/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var isToggle = false
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    
    var body: some View {
        Form {
            Section {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4.0).frame(width: 28, height: 28).foregroundStyle(.blue)
                        Image(systemName: "circle.righthalf.filled").foregroundStyle(.white)
                    }
                    
                    Picker("Appearance", selection: $colorSchemeManager.appearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }
            }
            
            Section {
                HStack(alignment: .center) {
                    Spacer()
                    VStack {
                        Image(systemName: "heart.fill").font(.system(size: 84.0)).foregroundStyle(.red)
                        
                        Text("Made With Love\nBy Chris Barlas").fontDesign(.rounded).fontWeight(.bold).foregroundStyle(.tertiary).multilineTextAlignment(.center)
                    }
                    Spacer()
                }.listRowBackground(Color.clear)
            }
        }.navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
    }
}

#Preview {
    SettingsView()
}
