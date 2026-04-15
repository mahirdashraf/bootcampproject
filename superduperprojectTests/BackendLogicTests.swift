import XCTest
@testable import superduperproject

final class BackendLogicTests: XCTestCase {
    func testEarningsEngine_duplicateBonusIsApplied() {
        let engine = EarningsEngine(config: .init(duplicateBonusRate: 0.10))
        let item = ItemModel(
            id: "a",
            name: "test",
            rarity: .common,
            universe: .spiderverse,
            baseEarningRate: 10,
            weight: nil,
            imageName: "x",
            spriteFileName: nil
        )

        XCTAssertEqual(engine.earningRate(for: item, duplicateCount: 0), 10, accuracy: 0.0001)
        XCTAssertEqual(engine.earningRate(for: item, duplicateCount: 1), 11, accuracy: 0.0001)
        XCTAssertEqual(engine.earningRate(for: item, duplicateCount: 3), 13, accuracy: 0.0001)
    }

    func testUserViewModel_offlineEarningsAccumulate() {
        let vm = UserViewModel(store: LocalPlayerStore(filename: "test_player.json"))
        vm.seedForTesting(
            totalMoney: 0,
            moneyPerSecond: 2,
            lastSavedDate: Date(timeIntervalSince1970: 0)
        )

        vm.applyOfflineEarnings(now: Date(timeIntervalSince1970: 10))
        XCTAssertEqual(vm.player.totalMoney, 20, accuracy: 0.0001)
    }

    func testBlindBoxService_rollRespectsPerDropWeights() {
        let svc = BlindBoxService()
        let a = ItemModel(id: "a", name: "a", rarity: .common, universe: .spiderverse, baseEarningRate: 0, weight: nil, imageName: "a", spriteFileName: nil)
        let b = ItemModel(id: "b", name: "b", rarity: .common, universe: .spiderverse, baseEarningRate: 0, weight: nil, imageName: "b", spriteFileName: nil)

        let weights = ["a": 0, "b": 1]
        for _ in 0..<50 {
            XCTAssertEqual(svc.rollItem(from: [a, b], perDropWeights: weights)?.id, "b")
        }
    }
}

