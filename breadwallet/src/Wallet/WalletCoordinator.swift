//
//  WalletCoordinator.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-01-07.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import Foundation
import UIKit

//TODO:CRYPTO rescan
/*
/// Coordinates the sync state of all wallet managers to
/// display the activity indicator and control backtround tasks
class WalletCoordinator: Subscriber, Trackable {
    
    // 24-hours until incremental rescan is reset
    private let incrementalRescanInterval: TimeInterval = (24*60*60)

    private var backgroundTaskId: UIBackgroundTaskIdentifier?
    private var walletManagers: [String: WalletManager]

    init(walletManagers: [String: WalletManager]) {
        self.walletManagers = walletManagers
        addSubscriptions()
    }

    private func addSubscriptions() {
        Reachability.addDidChangeCallback({ [weak self] isReachable in
            self?.reachabilityDidChange(isReachable: isReachable)
        })

        //Listen for sync state changes in all wallets
        Store.subscribe(self, selector: {
            for (key, val) in $0.wallets where val.syncState != $1.wallets[key]?.syncState {
                return true
            }
            return false
        }, callback: { [weak self] state in
            self?.syncStateDidChange(state: state)
        })

        Store.state.currencies.forEach { currency in
            Store.subscribe(self, name: .retrySync(currency), callback: { [weak self] _ in
                DispatchQueue.walletQueue.async {
                    self?.walletManagers[currency.code]?.peerManager?.connect()
                }
            })

            Store.subscribe(self, name: .rescan(currency), callback: { [weak self] _ in
                guard Store.state[currency]?.isRescanning == false else { return }
                Store.perform(action: WalletChange(currency).setIsRescanning(true))
                DispatchQueue.walletQueue.async {
                    self?.initiateRescan(currency: currency)
                }
            })
            
            // this is triggered by the wallet manager after a rejected transaction is detected (only applies to SPV wallets)
            Store.subscribe(self, name: .automaticRescan(currency), callback: { [weak self] _ in
                guard Store.state[currency]?.isRescanning == false else { return }
                print("[\(currency.code)] automatic rescan triggered")
                Store.perform(action: WalletChange(currency).setIsRescanning(true))
                DispatchQueue.walletQueue.async {
                    self?.initiateRescan(currency: currency)
                }
            })
        }
    }
    
    private func initiateRescan(currency: Currency) {
        guard let peerManager = self.walletManagers[currency.code]?.peerManager else { return assertionFailure() }
        peerManager.connect()
        
        // Rescans go deeper each time they are initiated within a 24-hour period.
        //
        // 1. Rescan goes from the last-sent tx.
        // 2. Rescan from peer manager's last checkpoint.
        // 3. Full rescan from block zero.
        //
        // Which type of rescan we perform is captured in `startingPoint`.
        
        var startingPoint = RescanState.StartingPoint.lastSentTx
        var blockHeight: UInt64?
        
        if let prevRescan = UserDefaults.rescanState(for: currency) {
            if abs(prevRescan.startTime.timeIntervalSinceNow) > incrementalRescanInterval {
                startingPoint = .lastSentTx
            } else {
                startingPoint = prevRescan.startingPoint.next
            }
        }
        
        if startingPoint == .lastSentTx {
            blockHeight = Store.state[currency]?.transactions
                .filter { $0.direction == .sent && $0.status == .complete }
                .map { $0.blockHeight }
                .max()
            if blockHeight == nil {
                startingPoint = startingPoint.next
            }
        }
                
        UserDefaults.setRescanState(for: currency, to: RescanState(startTime: Date(), startingPoint: startingPoint))
        
        // clear pending transactions
        if let txs = Store.state[currency]?.transactions {
            DispatchQueue.main.async {
                Store.perform(action: WalletChange(currency).setTransactions(txs.filter({ $0.status != .pending })))
            }
        }
        
        switch startingPoint {
        case .lastSentTx:
            print("[\(currency.code)] initiating rescan from block #\(blockHeight!)")
            
            let scanFromBlock = UInt32(blockHeight!)

            // Reset the 'last sync'd block height' for the currency in question so that
            // the sync progress can be calculated correctly when we start sync'ing
            // from 'blockHeight,' which may be an earlier block. (see BtcWalletManager.updateProgress()).
            UserDefaults.setLastSyncedBlockHeight(height: scanFromBlock, for: currency)
            
            peerManager.rescan(fromBlockHeight: scanFromBlock)
            
            // It's possible that the block we pass into rescan() will be newer than what
            // the peer manager actually ends up using as its starting point. Make sure
            // our last-sync'd-block reflects this otherwise our sync progress will be reported
            // incorrectly.
            let actualScanStartingBlock: UInt32 = peerManager.lastBlockHeight
            if actualScanStartingBlock != scanFromBlock {
                UserDefaults.setLastSyncedBlockHeight(height: actualScanStartingBlock, for: currency)
            }
            
        case .checkpoint:
            print("[\(currency.code)] initiating rescan from last checkpoint")
            peerManager.rescanFromLatestCheckpoint()
            // Ensure sync progress calculated in BtcWalletManager.updateProgress() is based on
            // the checkpoint chosen by the peer manager.
            UserDefaults.setLastSyncedBlockHeight(height: peerManager.lastBlockHeight, for: currency)
            
        case .walletCreation:
            print("[\(currency.code)] initiating rescan from earliestKeyTime")
            peerManager.rescanFull()
            // Ensure sync progress calculated in BtcWalletManager.updateProgress() is based on
            // the block from which it started the rescan.
            UserDefaults.setLastSyncedBlockHeight(height: peerManager.lastBlockHeight, for: currency)
        }
    }

    private func syncStateDidChange(state: State) {
        let allWalletsFinishedSyncing = state.wallets.values.filter { $0.syncState == .success}.count == state.wallets.values.count
        if allWalletsFinishedSyncing {
            endActivity()
            endBackgroundTask()
        } else {
            startActivity()
            startBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if let taskId = backgroundTaskId {
            UIApplication.shared.endBackgroundTask(taskId)
            backgroundTaskId = nil
        }
    }

    private func startBackgroundTask() {
        guard backgroundTaskId == nil else { return }
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            DispatchQueue.walletQueue.async {
                self.walletManagers.values.forEach {
                    $0.peerManager?.disconnect()
                }
            }
        })
    }

    private func reachabilityDidChange(isReachable: Bool) {
        if !isReachable {
            DispatchQueue.walletQueue.async {
                self.walletManagers.values.forEach {
                    $0.peerManager?.disconnect()
                }
                DispatchQueue.main.async {
                    Store.state.currencies.forEach {
                        Store.perform(action: WalletChange($0).setSyncingState(.connecting))
                    }
                }
            }
        }
    }

    private func startActivity() {
        UIApplication.shared.isIdleTimerDisabled = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    private func endActivity() {
        UIApplication.shared.isIdleTimerDisabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    deinit {
        Store.unsubscribe(self)
    }
}
*/

/// Rescan state of a currency - stored in UserDefaults
struct RescanState: Codable {
    enum StartingPoint: Int, Codable {
        // in order of latest to earliest
        case lastSentTx = 0
        case checkpoint
        case walletCreation
        
        var next: StartingPoint {
            return StartingPoint(rawValue: rawValue + 1) ?? .walletCreation
        }
    }
    
    var startTime: Date
    var startingPoint: StartingPoint = .lastSentTx
}
