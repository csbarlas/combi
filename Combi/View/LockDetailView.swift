//
//  LockDetailView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI

struct LockDetailView: View {
    var lock: Lock
    
    var body: some View {
        VStack(alignment: .center) {
            Text(lock.emoji).font(.system(size: 72))
            
            if let displayName = lock.displayName {
                Text(displayName).font(.largeTitle).bold()
            }
            
            if let lockerNumber = lock.lockerNumber {
                Text("No. " + lockerNumber).font(.title)
            }
            
            Text(lock.combination).font(.title).monospaced()
            
            Button {
                print("Edit Lock")
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    LockDetailView(lock: Lock(displayName: "LA Fitness Locker", lockerNumber: "1017", combination: "12 34 56"))
}
