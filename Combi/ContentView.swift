//
//  ContentView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<15) { item in
                    HStack {
                        Text("🔒").font(.system(size: 45))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Gym Locker").fontWeight(.bold)
                            Text("No. 1917AB").monospaced()
                            Text("012 34 56").monospaced()
                        }
                    }
                }
            }
            .navigationTitle("Your Locks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        print("settings")
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("hello")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
