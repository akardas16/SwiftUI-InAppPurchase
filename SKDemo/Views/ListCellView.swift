/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view for an individual car or subscription product that shows a Buy button when it displays within the store.
*/

import SwiftUI
import StoreKit

struct ListCellView: View {
    @EnvironmentObject var store: Store
    @State var isPurchased: Bool = false
    @State var errorTitle = ""
    @State var isShowingError: Bool = false

    let product: Product
    let purchasingEnabled: Bool


    init(product: Product , purchasingEnabled: Bool = true) {
        self.product = product
        //let p = Product()
        self.purchasingEnabled = purchasingEnabled
    }

    var body: some View {
        HStack {
            Image(systemName: "car.fill").font(.largeTitle).foregroundColor(Color.random)
            if purchasingEnabled {
                productDetail
                Spacer()
                buyButton
            } else {
                productDetail
            }
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
        })
    }

    @ViewBuilder
    var productDetail: some View {
        if product.type == .autoRenewable {
            VStack(alignment: .leading) {
                Text(product.displayName)
                    .bold()
                Text(product.description)
            }
        } else {
            Text(product.description)
                .frame(alignment: .leading)
        }
    }


    var buyButton: some View {
        Button {
            Task {
                await buy()
            }
        } label: {
            Capsule().fill(isPurchased ? .gray:.blue).frame(width: 150, height: 45).overlay {
                if !isPurchased{ //25.45 US$ / 6 Month
                    if let subscribtion = product.subscription {
                        Text("\(product.displayPrice)\n\(subscribtion.subscriptionPeriod.value) \(String(describing: subscribtion.subscriptionPeriod.unit))").font(.subheadline.bold()).foregroundColor(.white).multilineTextAlignment(.center)
                        
                    }else{
                        Text("Purchase").font(.headline.bold()).foregroundColor(.white)
                    }
                }else {
                    Text("Purchased \(Image(systemName: "checkmark"))").font(.headline.bold()).foregroundColor(.white)
                }
            }

        }.onAppear {
            Task {
                isPurchased = (try? await store.isPurchased(product)) ?? false
            }
        }.disabled(isPurchased)
        
    }

    func buy() async {
        do {
            if try await store.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}
