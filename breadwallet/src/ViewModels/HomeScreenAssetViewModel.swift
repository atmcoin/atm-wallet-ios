//
//  AssetCardViewModel.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-01-31.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import Foundation

struct HomeScreenAssetViewModel {
    let currency: Currency
    
    var exchangeRate: String {
        guard let rate = currency.state?.currentRate else { return "" }
        let placeholderAmount = Amount.zero(currency, rate: rate)
        guard let rateText = placeholderAmount.localFormat.string(from: NSNumber(value: rate.rate)) else { return "" }
        return rateText
    }
    
    var fiatBalance: String {
        guard let rate = currency.state?.currentRate else { return "" }
        return balanceString(inFiatWithRate: rate)
    }
    
    var tokenBalance: String {
        return balanceString()
    }
    
    /// Returns balance string in fiat if rate specified or token amount otherwise
    private func balanceString(inFiatWithRate rate: Rate? = nil) -> String {
        guard let balance = currency.state?.balance else { return "" }
        return Amount(amount: balance,
                      rate: rate).description
    }
}
