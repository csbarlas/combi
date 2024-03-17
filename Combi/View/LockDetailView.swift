//
//  LockDetailView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI

struct LockDetailView: View {
    var lock: Lock
    
    @State private var showLockFormPopover = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text(lock.emoji.emojiString).font(.system(size: 72))
            
            if let displayName = lock.displayName {
                Text(displayName).font(.largeTitle).bold()
            }
            
            if let lockerNumber = lock.lockerNumber {
                Text("No. " + lockerNumber).font(.title).monospaced()
            }
            
            Text(lock.combination).font(.title).monospaced()
            
            Button {
                showLockFormPopover = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .popover(isPresented: $showLockFormPopover, content: {
                    LockFormView(lock: lock)
                })
        }.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LockDetailView(lock: Lock(displayName: "LA Fitness Locker", lockerNumber: "1017", combination: "12 34 56", numberOfSegments: 3, segmentLength: 2, acceptedValues: .numeric))
}
