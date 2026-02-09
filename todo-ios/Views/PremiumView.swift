import SwiftUI
import StoreKit

struct PremiumView: View {
    @StateObject private var storeKit = StoreKitManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .padding()
            
            Text("Upgrade to Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "chart.bar.xaxis", text: "Advanced Analytics")
                FeatureRow(icon: "wand.and.stars", text: "AI Task Assistant")
                FeatureRow(icon: "calendar", text: "Calendar Sync")
                FeatureRow(icon: "person.2.fill", text: "Unlimited Collaboration")
                FeatureRow(icon: "lock.shield", text: "Biometric Security")
            }
            .padding()
            
            if storeKit.isPremium {
                Text("You are a Premium Member!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
            } else {
                VStack(spacing: 15) {
                    ForEach(storeKit.products) { product in
                        Button {
                            Task {
                                try? await storeKit.purchase(product)
                            }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            try? await AppStore.sync()
                            await storeKit.updatePurchasedProducts()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
