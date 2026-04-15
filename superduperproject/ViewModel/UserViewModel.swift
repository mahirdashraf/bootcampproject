//
//  UserViewModel.swift
//  
//
//  Created by Ashley Ni on 4/6/26.
//
import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published private(set) var player: PlayerModel

    private let store: LocalPlayerStore
    private var currentUserID: String?
    private let earningsEngine: EarningsEngine
    private let blindBoxService: BlindBoxService
    private let syncService: PlayerSyncServiceProtocol

    private var earningTimer: Timer?

    private var itemLookup: (String) -> ItemModel? = { _ in nil }

    // sets up the user vm with local storage + earnings math
    init(
        store: LocalPlayerStore = LocalPlayerStore(),
        earningsEngine: EarningsEngine = EarningsEngine(),
        blindBoxService: BlindBoxService = BlindBoxService(),
        syncService: PlayerSyncServiceProtocol = NoopPlayerSyncService()
    ) {
        self.store = store
        self.earningsEngine = earningsEngine
        self.blindBoxService = blindBoxService
        self.syncService = syncService
        self.player = PlayerModel(
            id: "local",
            displayName: nil,
            totalMoney: 0,
            moneyPerSecond: 0,
            lastSavedDate: Date(),
            inventory: [],
            unlockedWorlds: [],
            boxesOpened: 0
        )
    }

    // tells the vm which authed user id to use (from auth vm)
    func setAuthenticatedUserID(_ userID: String?) {
        currentUserID = userID
        if let userID {
            player.id = userID
        }
    }

    // loads the last saved player from disk if it exists
    func loadPlayer() {
        do {
            if let loaded = try store.load() {
                player = loaded
            }
        } catch {
            // ignore
        }
    }

    // tries cloud load first, falls back to local, then refreshes earnings rate
    func loadPlayerPreferCloud() {
        guard let userID = currentUserID, !userID.isEmpty else {
            loadPlayer()
            recomputeMoneyPerSecond()
            return
        }

        Task { @MainActor in
            do {
                if let cloud = try await syncService.loadPlayer(userID: userID) {
                    player = cloud
                } else {
                    loadPlayer()
                }
            } catch {
                loadPlayer()
            }
            recomputeMoneyPerSecond()
        }
    }

    // saves the current player to disk (and stamps lastSavedDate)
    func saveToLocal() {
        player.lastSavedDate = Date()
        do {
            try store.save(player)
        } catch {
            // ignore
        }
    }

    // sends the current player to cloud (best effort)
    func saveToCloud() {
        Task {
            do { try await syncService.savePlayer(player) } catch {}
        }
    }

    // applies earnings since the last save (for when the app was closed)
    func applyOfflineEarnings(now: Date = Date()) {
        let elapsed = max(0, now.timeIntervalSince(player.lastSavedDate))
        let earned = elapsed * player.moneyPerSecond
        if earned > 0 {
            player.totalMoney += earned
        }
        player.lastSavedDate = now
    }

    // adds money directly (useful for preview/demo controls)
    func addMoney(_ amount: Double) {
        guard amount > 0 else { return }
        player.totalMoney += amount
    }

    // runs offline earnings as if the app was away for N seconds
    func simulateOffline(seconds: TimeInterval) {
        guard seconds > 0 else { return }
        player.lastSavedDate = Date().addingTimeInterval(-seconds)
        applyOfflineEarnings()
    }

    // test helper to seed deterministic player values
    func seedForTesting(totalMoney: Double, moneyPerSecond: Double, lastSavedDate: Date) {
        player.totalMoney = totalMoney
        player.moneyPerSecond = moneyPerSecond
        player.lastSavedDate = lastSavedDate
    }

    // lifecycle hook: load -> recompute rate -> offline earnings -> start timer
    func handleAppDidBecomeActive() {
        loadPlayerPreferCloud()
        applyOfflineEarnings()
        startEarningLoop()
    }

    // lifecycle hook: stop timer then save
    func handleAppDidEnterBackground() {
        stopEarningLoop()
        saveToLocal()
        saveToCloud()
    }

    // lets whoever owns the item catalog plug in a lookup by id
    func setItemLookup(_ lookup: @escaping (String) -> ItemModel?) {
        itemLookup = lookup
        recomputeMoneyPerSecond()
    }

    // recomputes moneyPerSecond from the current inventory
    func recomputeMoneyPerSecond() {
        player.moneyPerSecond = earningsEngine.moneyPerSecond(inventory: player.inventory, itemLookup: itemLookup)
    }

    // starts the 1s earning timer (no-op if already running)
    func startEarningLoop() {
        guard earningTimer == nil else { return }
        earningTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.player.totalMoney += self.player.moneyPerSecond
        }
    }

    // stops the 1s earning timer
    func stopEarningLoop() {
        earningTimer?.invalidate()
        earningTimer = nil
    }

    struct OpenBoxResult: Hashable {
        var wonItemID: String
        var wonItemRarity: Rarity
        var newBalance: Double
    }

    enum OpenBoxError: Error, Hashable {
        case missingItemCatalog
        case emptyPool
        case insufficientFunds
        case rollFailed
    }

    // opens a themed box, updates inventory + balance, then saves locally
    func openBlindBox(_ box: BlindBoxModel) throws -> OpenBoxResult {
        guard player.totalMoney >= box.cost else { throw OpenBoxError.insufficientFunds }

        let pool: [ItemModel] = box.possibleDropItemIDs.compactMap { itemLookup($0) }
        guard !pool.isEmpty else { throw OpenBoxError.emptyPool }

        guard let rolled = blindBoxService.rollItem(from: pool, perDropWeights: box.perDropWeights) else {
            throw OpenBoxError.rollFailed
        }

        player.totalMoney -= box.cost
        player.boxesOpened += 1

        if let idx = player.inventory.firstIndex(where: { $0.itemID == rolled.id }) {
            player.inventory[idx].duplicateCount += 1
        } else {
            player.inventory.append(InventoryEntry(itemID: rolled.id, duplicateCount: 0))
        }

        recomputeMoneyPerSecond()
        saveToLocal()
        saveToCloud()

        return OpenBoxResult(wonItemID: rolled.id, wonItemRarity: rolled.rarity, newBalance: player.totalMoney)
    }
}

// hey tm2 this vm only depends on PlayerSyncServiceProtocol, plug your firebase impl in at init and it should work
// hey tm3 openbox result payload is stable: wonitemid, wonitemrarity, newbalance
