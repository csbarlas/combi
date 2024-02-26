//
//  SettingsView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/26/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var isToggle = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4.0).frame(width: 28, height: 28).foregroundStyle(.blue)
                        
                    }
                    Toggle("Toggle", isOn: $isToggle)
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
    }
}

#Preview {
    SettingsView()
}
