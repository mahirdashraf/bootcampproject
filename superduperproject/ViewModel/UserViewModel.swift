//
//  UserViewModel.swift
//  
//
//  Created by Ashley Ni on 4/6/26.
//
import Foundation
import Combine
import FirebaseFirestore
import Firebase
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var player: PlayerModel

    private var store: LocalPlayerStore?
    private var currentUserID: String?
    private let earningsEngine: EarningsEngine
    private let blindBoxService: BlindBoxService
    private let syncService: PlayerSyncServiceProtocol
    private var didLoadInitialUser = false
    @Published var isLoading = false
    private var isSyncing = false
    private var listener: ListenerRegistration?
    private var previousUserID: String?

    private var earningTimer: Timer?

    private var itemLookup: (String) -> ItemModel? = { _ in nil }

    // sets up the user vm with local storage + earnings math
    init(
//        store: LocalPlayerStore = LocalPlayerStore(),
        earningsEngine: EarningsEngine = EarningsEngine(),
        blindBoxService: BlindBoxService = BlindBoxService(),
        syncService: PlayerSyncServiceProtocol = FirestorePlayerSyncService()
    ) {
//        self.store = store
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
        if userID == previousUserID {
             return
         }
        previousUserID = userID
        guard let userID else {
            store = nil
            currentUserID = nil
            player = PlayerModel(
                id: "local",
                displayName: nil,
                totalMoney: 0,
                moneyPerSecond: 0,
                lastSavedDate: Date(),
                inventory: [],
                unlockedWorlds: [],
                boxesOpened: 0
            )
            return
        }
        currentUserID = userID
        store = LocalPlayerStore(userID: userID)
        player.id = userID
        self.listenToPlayer()

        Task {
            await createPlayerIfNeeded(uid: userID)
            await MainActor.run {
                loadPlayerPreferCloud()
            }
        }
        guard !didLoadInitialUser else {
            currentUserID = userID
            return
        }
        didLoadInitialUser = true
    }
    
    // loads the last saved player from disk if it exists
    func loadPlayer() {
        do {
            if let loaded = try store?.load() {
                player = loaded
            }
        } catch {
            // ignore
        }
    }

    // tries cloud load first then falls back to local, then refreshes earnings rate
//    func loadPlayerPreferCloud() async {
//        guard let userID = currentUserID, !userID.isEmpty else {
//            loadPlayer()
//            recomputeMoneyPerSecond()
//            return
//        }
//
//        Task { @MainActor [weak self] in
//            guard let self else { return }
//            do {
//                if let cloud = try await syncService.loadPlayer(userID: userID) {
//                    player = cloud
//                } else {
//                    loadPlayer()
//                }
//            } catch {
//                loadPlayer()
//            }
//            recomputeMoneyPerSecond()
//        }
//    }
    func loadPlayerPreferCloud() {
        guard let userID = currentUserID, !userID.isEmpty else {
            loadPlayer()
            recomputeMoneyPerSecond()
            return
        }
        guard !isLoading else { return }
        isLoading = true

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                if let cloud = try await syncService.loadPlayer(userID: userID) {
                    print("loaded from cloud: money=\(cloud.totalMoney), inventory=\(cloud.inventory.count) items")
                    self.player = cloud
                } else {
                    print("no cloud document found, falling back to local")
                    self.loadPlayer()
                }            } catch {
                self.loadPlayer()
            }

            self.recomputeMoneyPerSecond()
            self.applyOfflineEarnings()
            self.startEarningLoop()
            self.isLoading = false
        }
    }
    // saves the current player to disk (and stamps lastSavedDate)
    func saveToLocal() {
        player.lastSavedDate = Date()
        do {
            try store?.save(player)
        } catch {
            // ignore
        }
    }

    // sends the current player to cloud (best effort)
    func saveToCloud() {
        print("saveToCloud called, playerID: \(player.id ?? "nil"), isLoading: \(isLoading)")
        guard !isLoading else {
            print("saveToCloud blocked by isLoading")
            return
        }
        Task {
            do {
                try await syncService.savePlayer(player)
                print("saveToCloud succeeded")
            } catch {
                print("saveToCloud failed:", error)
            }
        }
    }    // applies earnings since the last save (for when the app was closed)
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
            if currentUserID != nil && !isLoading {
                applyOfflineEarnings()
            }
            startEarningLoop()
        }

    // lifecycle hook: stop timer then save
    func handleAppDidEnterBackground() {
        stopEarningLoop()
        updateAndSync()
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
            if Int.random(in: 0..<10) == 0 {
                self.updateAndSync()
            }
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
        updateAndSync()

        return OpenBoxResult(wonItemID: rolled.id, wonItemRarity: rolled.rarity, newBalance: player.totalMoney)
    }
    func createPlayerIfNeeded(uid: String) async {
        let docRef = Firestore.firestore().collection("users").document(uid)

        do {
            let snapshot = try await docRef.getDocument()

            if !snapshot.exists {
                let newPlayer = PlayerModel(
                    id: uid,
                    displayName: nil,
                    totalMoney: 0,
                    moneyPerSecond: 0,
                    lastSavedDate: Date(),
                    inventory: [],
                    unlockedWorlds: [],
                    boxesOpened: 0
                )
                try docRef.setData(from: newPlayer)
            }
        } catch {
            print("Failed to create player:", error)
        }
    }
    func updateAndSync() {
        guard !isSyncing else { return }
        isSyncing = true
        player.lastSavedDate = Date()
        saveToLocal()
        Task {
            do {
                try await syncService.savePlayer(player)
            } catch {
                print("Firestore save failed:", error)
            }
            await MainActor.run {
                self.isSyncing = false
            }
        }
    }
    @MainActor
    func addMoneyFromGame(_ amount: Double) {
        player.totalMoney += amount
        player.lastSavedDate = Date()
        updateAndSync()
    }
    func listenToPlayer() {
        guard let userID = currentUserID else { return }
        listener?.remove()
        listener = Firestore.firestore()
            .collection("users")
            .document(userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self,
                      let data = try? snapshot?.data(as: PlayerModel.self),
                      error == nil else { return }
                DispatchQueue.main.async {
                    if data.totalMoney >= self.player.totalMoney {
                        self.player = data
                    }
                }
            }
    }
}
