//
//  LockDetailView.swift
//  CombiWatch Watch App
//
//  Created by Christopher Barlas on 3/1/24.
//

import SwiftUI

struct LockDetailView: View {
    var lock: Lock
    
    var body: some View {
        VStack {
            Text(lock.emoji.emojiString).font(.largeTitle)
            
            Text(lock.displayName ?? "Lock").fontWeight(.bold)
            
            Text(lock.combination).monospaced()
        }
    }
}

#Preview {
    LockDetailView(lock: Lock.sampleLock())
}
