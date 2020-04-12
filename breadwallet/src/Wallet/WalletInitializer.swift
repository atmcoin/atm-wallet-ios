// 
//  WalletInitializer.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2020-04-11.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

class WalletInitializer: Subscriber {
    
    init() {
        Store.subscribe(self, name: .initializeNetwork(nil, nil, nil)) { [weak self] trigger in
            if case let .initializeNetwork(network, system, callback) = trigger {
                if let network = network, let system = system, let callback = callback {
                    self?.initializeWallet(network: network, system: system, callback: callback)
                }
            }
        }
        
    }
    
    private func initializeWallet(network: Network, system: System, callback: @escaping () -> Void) {
        print ("[SYS] initialize: \(network.name)")
        guard network.currency.uid == Currencies.hbar.uid else { return }
        guard !system.accountIsInitialized(system.account, onNetwork: network) else {
            print ("[SYS] skipping, account is initialized")
            return
        }
        
        system.accountInitialize (system.account, onNetwork: network) { (res: Result<Data, System.AccountInitializationError>) in
            var serializationData: Data?
            switch res {
            case .success (let data):
                serializationData = data
            case .failure (let error):
                switch error {
                case .alreadyInitialized:
                    print ("[SYS] system : Already Initialized")
                case .multipleHederaAccounts(let accounts):
                    let accountDescriptions = accounts
                            .map { "{id: \($0.id), balance: \($0.balance)}"}
                    print ("[SYS] system: Multiple Hedera Accounts: \(accountDescriptions.joined(separator: ", "))")

                    //TODO:HBAR - handle multiple HBAR accounts
                    // Chose the Hedera account with the largest balance - DEMO-SPECFIC
                    let hederaAccount = accounts.sorted { $0.balance > $1.balance }[0]
                    serializationData = system.accountInitialize (system.account,
                                                                  onNetwork: network,
                                                                  hedera: hederaAccount)

                case .queryFailure(let message):
                    print ("[SYS] system: Initalization Query Error: \(message)")

                case .cantCreate:
                    print ("[SYS] system: Initializaiton: Can't Create")
                }
            }

            if let serializationData = serializationData {
                callback()
                print ("SYS: system: SerializationData: \(CoreCoder.hex.encode(data: serializationData)!)")
            } else {
                print ("SYS: system: skipped hedera due to no serialization")
            }
        }
    }
}
