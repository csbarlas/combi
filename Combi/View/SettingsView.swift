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
    @AppStorage("redact") var redact: Bool = false
    @EnvironmentObject var store: StoreManager
    
    var body: some View {
        Form {
            Section {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4.0).frame(width: 28, height: 28).foregroundStyle(.yellow)
                        Image(systemName: "star.fill").foregroundStyle(.white)
                    }
                    
                    NavigationLink {
                        StoreView().environmentObject(store)
                    } label: {
                        Text("Combi Pro")
                    }
                }
                
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
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4.0).frame(width: 28, height: 28).foregroundStyle(.purple)
                        Image(systemName: "eye.slash.fill").foregroundStyle(.white)
                    }
                    
                    Toggle("Hide Combinations In List", isOn: $redact)
                }
            }
            
            Section {
                HStack(alignment: .center) {
                    Spacer()
                    VStack {
                        Text("Made With").fontDesign(.rounded).fontWeight(.bold).foregroundStyle(.tertiary).multilineTextAlignment(.center)
                        
                        Image(systemName: "heart.fill").font(.system(size: 64.0)).foregroundStyle(.red)
                        
                        Text("By Chris Barlas").fontDesign(.rounded).fontWeight(.bold).foregroundStyle(.tertiary).multilineTextAlignment(.center)
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
