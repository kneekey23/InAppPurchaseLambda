//
//  ContentView.swift
//  InAppPurchaseApp
//
//  Created by Stone, Nicki on 12/10/20.
//

import SwiftUI
import StoreKit

struct ContentView: View {
   // @Binding var purchased:Bool
    @ObservedObject var products = productsDB.shared
    @State var receiptIsValid = false
    var body: some View {
        NavigationView {
            ForEach(self.products.items, id: \.self) { product in
                ProductCell(name: product.localizedDescription,
                            subtitle: "AWS Framed Quote",
                            product: product,
                            receiptIsValid: receiptIsValid)
            }.navigationTitle("Reinvent Sale")
            .navigationBarItems(trailing:
                Button("Restore") {
                    IAPManager.shared.restorePurchasesV5()
                }
            )
        }.onAppear() {
            IAPManager.shared.getProductsV5()
            // If a receipt is present validate it
            if ReceiptManager.isReceiptPresent() {
                ReceiptManager.loadAndValidateReceipt { (valid) in
                    receiptIsValid = valid
                }
               
            } 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
