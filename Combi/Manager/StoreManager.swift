//
//  StoreManager.swift
//  Combi
//
//  Created by Christopher Barlas on 3/20/24.
//  Reference: Meet StoreKit 2 (WWDC21)
//
//  License from SKDemo Project Files:
//
//  Copyright © 2023 Apple Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import StoreKit

class StoreManager: ObservableObject {
    @Published private(set) var products: [Product]
    @Published private(set) var isProPurchased: Bool = false
    @Published private(set) var purchasedProducts: [Product]
    let productIds: [String]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    public enum StoreError: Error {
        case failedVerification
    }
    
    init() {
        productIds = StoreManager.loadProductIds()
        products = []
        purchasedProducts = []
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCustomerProductStatus()
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
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedProducts: [Product] = []

        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                //Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    if let purchasedProduct = products.first(where: { $0.id == transaction.productID }) {
                        purchasedProducts.append(purchasedProduct)
                        isProPurchased = true
                    }
                default:
                    break
                }
            } catch {
                //TODO: ?
                print()
            }
        }

        //Update the store information with the purchased products.
        self.purchasedProducts = purchasedProducts
    }
    
    func isPurchased(_ product: Product) async throws -> Bool {
        //Determine whether the user purchases a given product.
        switch product.type {
        case .nonConsumable:
            return purchasedProducts.contains(product)
        default:
            return false
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
