import SwiftUI
import FirebaseCore
import FirebaseAuth

struct ContentPreview: View {
    @StateObject private var userVM = UserViewModel()

    private let catalog: [String: ItemModel] = [
        "miles": .init(
            id: "miles",
            name: "Miles Morales",
            rarity: .legendary,
            universe: .spiderverse,
            baseEarningRate: 8,
            weight: nil,
            imageName: "miles",
            spriteFileName: nil
        ),
        "gwen": .init(
            id: "gwen",
            name: "Gwen Stacy",
            rarity: .rare,
            universe: .spiderverse,
            baseEarningRate: 4,
            weight: nil,
            imageName: "gwen",
            spriteFileName: nil
        ),
        "peter": .init(
            id: "peter",
            name: "Peter Parker",
            rarity: .uncommon,
            universe: .spiderverse,
            baseEarningRate: 2,
            weight: nil,
            imageName: "peter",
            spriteFileName: nil
        ),
        "jessica": .init(
            id: "jessica",
            name: "Jessica Drew",
            rarity: .common,
            universe: .spiderverse,
            baseEarningRate: 1,
            weight: nil,
            imageName: "jessica",
            spriteFileName: nil
        ),
        "keroppi": .init(
            id: "keroppi",
            name: "Keroppi",
            rarity: .legendary,
            universe: .hellokittyverse,
            baseEarningRate: 8,
            weight: nil,
            imageName: "keroppi",
            spriteFileName: nil
        ),
        "chococat": .init(
            id: "chococat",
            name: "Chococat",
            rarity: .rare,
            universe: .hellokittyverse,
            baseEarningRate: 4,
            weight: nil,
            imageName: "chococat",
            spriteFileName: nil
        ),
        "hellokitty": .init(
            id: "hellokitty",
            name: "Hello Kitty",
            rarity: .uncommon,
            universe: .hellokittyverse,
            baseEarningRate: 2,
            weight: nil,
            imageName: "hellokitty",
            spriteFileName: nil
        ),
        "kuromi": .init(
            id: "kuromi",
            name: "Kuromi",
            rarity: .common,
            universe: .hellokittyverse,
            baseEarningRate: 1,
            weight: nil,
            imageName: "kuromi",
            spriteFileName: nil
        ),
        "peach": .init(
            id: "peach",
            name: "Princess Peach",
            rarity: .legendary,
            universe: .marioverse,
            baseEarningRate: 8,
            weight: nil,
            imageName: "peach",
            spriteFileName: nil
        ),
        "mario": .init(
            id: "mario",
            name: "Mario",
            rarity: .rare,
            universe: .marioverse,
            baseEarningRate: 4,
            weight: nil,
            imageName: "mario",
            spriteFileName: nil
        ),
        "luigi": .init(
            id: "luigi",
            name: "Luigi",
            rarity: .uncommon,
            universe: .marioverse,
            baseEarningRate: 2,
            weight: nil,
            imageName: "luigi",
            spriteFileName: nil
        ),
        "toad": .init(
            id: "toad",
            name: "Toad",
            rarity: .common,
            universe: .marioverse,
            baseEarningRate: 1,
            weight: nil,
            imageName: "toad",
            spriteFileName: nil
        )
    ]

    private var spiderBox: BlindBoxModel {
        .init(
            id: "spiderverse_box",
            name: "Spiderverse Box",
            universe: .spiderverse,
            cost: 50,
            possibleDropItemIDs: ["miles", "gwen", "peter", "jessica"],
            perDropWeights: nil,
            boxImageName: "spiderverse_box"
        )
    }

    private var helloKittyBox: BlindBoxModel {
        .init(
            id: "hellokittyverse_box",
            name: "Hello Kittyverse Box",
            universe: .hellokittyverse,
            cost: 30,
            possibleDropItemIDs: ["keroppi", "chococat", "hellokitty", "kuromi"],
            perDropWeights: nil,
            boxImageName: "hellokittyverse_box"
        )
    }

    private var marioBox: BlindBoxModel {
        .init(
            id: "marioverse_box",
            name: "Marioverse Box",
            universe: .marioverse,
            cost: 40,
            possibleDropItemIDs: ["peach", "mario", "luigi", "toad"],
            perDropWeights: nil,
            boxImageName: "marioverse_box"
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("money: \(userVM.player.totalMoney, specifier: "%.2f")")
                Text("money per second: \(userVM.player.moneyPerSecond, specifier: "%.2f")")
                Text("boxes opened: \(userVM.player.boxesOpened)")
                Text("inventory:")
                ForEach(userVM.player.inventory, id: \.self) { entry in
                    Text("- \(entry.itemID) (dupes: \(entry.duplicateCount))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                Button("simulate active") { userVM.handleAppDidBecomeActive() }
                Button("simulate background") { userVM.handleAppDidEnterBackground() }
            }

            HStack(spacing: 10) {
                Button("give $20") { userVM.addMoney(20) }
                Button("offline +10s") {
                    userVM.simulateOffline(seconds: 10)
                }
            }

            Button("open spiderverse box ($5)") {
                do { _ = try userVM.openBlindBox(spiderBox) } catch { print(error) }
            }
            .buttonStyle(.borderedProminent)

            Button("open hello kittyverse box ($5)") {
                do { _ = try userVM.openBlindBox(helloKittyBox) } catch { print(error) }
            }
            .buttonStyle(.borderedProminent)

            Button("open marioverse box ($5)") {
                do { _ = try userVM.openBlindBox(marioBox) } catch { print(error) }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            userVM.setItemLookup { catalog[$0] }
            userVM.handleAppDidBecomeActive()
        }
    }
}

#if DEBUG
private struct LoginPreviewHarness: View {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var userVM = UserViewModel()

    var body: some View {
        ContentView()
            .environmentObject(auth)
            .environmentObject(userVM)
            .onAppear {
                if FirebaseApp.app() == nil {
                    FirebaseApp.configure()
                }
            }
            .onReceive(auth.$user) { user in
                userVM.setAuthenticatedUserID(user?.uid)
            }
    }
}
#endif

#Preview {
    ContentPreview()
}

#Preview("login preview") {
    LoginPreviewHarness()
}

