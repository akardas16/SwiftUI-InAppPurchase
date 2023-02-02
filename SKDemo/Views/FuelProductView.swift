/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A product view for an individual product type.
*/

import SwiftUI
import StoreKit

struct FuelProductView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: Store
    @State private var errorTitle = ""
    @State private var isShowingError = false

    let product: Product
    let onPurchase: (Product) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "car.fill").font(.largeTitle).foregroundColor(Color.random)
            Text(product.description)
                .bold()
                .foregroundColor(Color.black)
                .clipShape(Rectangle())
                .padding(10)
                .background(Color.yellow)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                .padding(.bottom, 5)
            buyButton
                
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
        })
    }

    var buyButton: some View {
        Button(action: {
            Task {
                await purchase()
            }
        }) {
            Text(product.displayPrice)
                .foregroundColor(.white)
                .bold()
        }
    }

    @MainActor
    func purchase() async {
        do {
            if try await store.purchase(product) != nil {
                onPurchase(product)
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed fuel purchase: \(error)")
        }
    }
}

//struct FuelProductView_Previews: PreviewProvider {
//    static var previews: some View {
//        FuelProductView(product: "") { product in
//            
//        }
//    }
//}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
