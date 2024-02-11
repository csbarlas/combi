//
//  NewLockView.swift
//  Combi
//
//  Created by Christopher Barlas on 2/10/24.
//

import SwiftUI

struct NewLockView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var emoji = ""
    @State private var displayName = ""
    @State private var lockerNo = ""
    @State private var combination = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Lock Details")) {
                        TextField("Emoji", text: $emoji)
                        TextField("Combination", text: $combination).monospaced()
                    }
                    
                    Section(header: Text("Optional")) {
                        TextField("Nickname", text: $displayName)
                        TextField("Locker Number", text: $lockerNo)
                    }
                }
            }
            .navigationTitle("New Lock")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Button("Submit") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NewLockView()
}
