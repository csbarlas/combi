//
//  StoreManager.swift
//  Combi
//
//  Created by Christopher Barlas on 3/20/24.
//  Reference: Meet StoreKit 2 (WWDC21)
//

import Foundation
import StoreKit

class StoreManager: ObservableObject {
    @Published private(set) var products: [Product]
    let productIds: [String]
    
    init() {
        productIds = StoreManager.loadProductIds()
        products = []
        
        Task {
            await requestProducts()
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIds)
        } catch {
            print("An error occured receiving products from App Store: \(error)")
        }
    }
    
    static func loadProductIds() -> [String] {
        guard let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
              let plist = FileManager.default.contents(atPath: path),
              let data = try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String] else {
            return [String]()
        }
        return data
    }
}
