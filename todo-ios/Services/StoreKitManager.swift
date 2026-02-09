import Foundation
import StoreKit
import Combine

class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    // Define your product IDs from App Store Connect
    private let productDict: [String: String] = [
        "com.todo.premium.monthly": "Monthly Subscription",
        "com.todo.premium.yearly": "Yearly Subscription"
    ]
    
    init() {
        Task {
            await requestProducts()
            await updatePurchasedProducts()
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productDict.keys)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await updatePurchasedProducts()
            case .unverified:
                break
            }
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
}
