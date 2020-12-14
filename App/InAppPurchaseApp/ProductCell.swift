//
//  Product.swift
//  InAppPurchaseApp
//
//  Created by Stone, Nicki on 12/10/20.
//

import SwiftUI
import StoreKit

struct ProductCell: View {
    let name: String
    let subtitle: String
    let product: SKProduct
    let receiptIsValid: Bool
    var body: some View {
        HStack {
            VStack {
                Text(name)
                Text(subtitle)
                    .font(.system(size: 10))
            }
            Spacer()
            if !receiptIsValid {
            Button("Buy") {
                IAPManager.shared.purchaseV5(product: product)
            }.foregroundColor(Color.blue)
            } else {
                Image("checkmark")
            }
        }.padding(10)
        .listRowBackground(Color.gray)
    }
}

struct Product_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(name: "Test", subtitle: "Test", product: SKProduct(), receiptIsValid: false)
    }
}
