//
//  StoreView.swift
//  Combi
//
//  Created by Christopher Barlas on 3/20/24.
//

import SwiftUI
import StoreKit

struct StoreView: View {
    @EnvironmentObject var store: StoreManager
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Button("Restore Purchases") {
                    Task {
                        try? await AppStore.sync()
                    }
                }
            }
            VStack {
                VStack {
                    Text("Combi Pro").fontWeight(.heavy).font(.system(size: 52.0))
                    Text("Support indie development and manage unlimited locks!").font(.title2).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                if let firstId = store.productIds.first {
                    ProductView(id: firstId) {
                        Image("combi-pro-icon").resizable().frame(width: 100, height: 100).clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.background.secondary, in: .rect(cornerRadius: 20))
                }
            }
            .padding()
        }.frame(maxHeight: .infinity)
    }
}

#Preview {
    let store = StoreManager()
    return StoreView().environmentObject(store)
}
