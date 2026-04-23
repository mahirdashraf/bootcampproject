//
//  StoreView.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/15/26.
//

import SwiftUI

struct StoreView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showResult = false
    @State private var errorMessage: String?
    @State private var showUnboxAnimation = false
    @State private var selectedBoxImageName = ""
    @State private var selectedCharacterImageName = ""
    @State private var selectedCharacterName = ""
    @State private var selectedRarityText = ""
    @State private var selectedMpsText = ""
    
    private var blindBoxes: [BlindBoxModel] {
        GameCatalog.blindBoxes
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(blindBoxes, id: \.id) { box in
                            VStack(spacing: 10) {
                                Image(box.boxImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipped()
                                    .background(Color(red: 0.3, green: 0.3, blue: 0.5))
                                    .cornerRadius(8)
                                
                                Text(box.universe.rawValue.uppercased())
                                    .font(.custom("PressStart2P-Regular", size: 10))
                                    .foregroundColor(.white)
                                
                                Text("$\(Int(box.cost))")
                                    .font(.custom("PressStart2P-Regular", size: 12))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    do {
                                        let result = try userViewModel.openBlindBox(box)
                                        let character = GameCatalog.itemCatalog[result.wonItemID]
                                        selectedBoxImageName = box.boxImageName
                                        selectedCharacterImageName = character?.imageName ?? result.wonItemID
                                        selectedCharacterName = character?.name ?? result.wonItemID.uppercased()
                                        selectedRarityText = result.wonItemRarity.rawValue.uppercased()
                                        selectedMpsText = character.map { String(format: "%.1f", $0.baseEarningRate) } ?? "0"
                                        showUnboxAnimation = true
                                        errorMessage = nil
                                        showResult = false
                                    } catch {
                                        errorMessage = "Not enough money! Need $\(Int(box.cost))"
                                        showResult = true
                                    }
                                }) {
                                    Text("BUY")
                                        .font(.custom("PressStart2P-Regular", size: 10))
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(Color(red: 0.6, green: 1.0, blue: 0.6))
                                        .foregroundColor(.black)
                                        .cornerRadius(4)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                
                NavigationLink(destination: CharacterArchiveView(userViewModel: userViewModel)) {
                    Text("CHARACTER ARCHIVES")
                        .font(.custom("PressStart2P-Regular", size: 14))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.8, green: 0.6, blue: 1.0))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                HStack(spacing: 15) {
                    VStack(spacing: 5) {
                        Text("BALANCE")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                        Text("$\(Int(userViewModel.player.totalMoney))")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    
                    VStack(spacing: 5) {
                        Text("MPS")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(.white)
                        Text("$\(Int(userViewModel.player.moneyPerSecond))")
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.6))
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                VStack(spacing: 5) {
                    Text("BOXES OPENED")
                        .font(.custom("PressStart2P-Regular", size: 12))
                        .foregroundColor(.white)
                    Text("\(userViewModel.player.boxesOpened)")
                        .font(.custom("PressStart2P-Regular", size: 16))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
    
                Button(action: {
                    userViewModel.addMoney(20.0)
                    userViewModel.saveToLocal()
                }) {
                    Text("TAP FOR MONEY")
                        .font(.custom("PressStart2P-Regular", size: 12))
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color(red: 0.6, green: 1.0, blue: 0.6))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("BACK")
                            .font(.custom("PressStart2P-Regular", size: 14))
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                            .foregroundColor(.black)
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.9))
            .navigationBarBackButtonHidden(true)
            .onAppear {
                userViewModel.setItemLookup { GameCatalog.itemCatalog[$0] }
            }
            .alert("Error", isPresented: $showResult) {
                Button("OK") {
                    showResult = false
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }

            if showUnboxAnimation {
                Color.black.opacity(0.82)
                    .ignoresSafeArea()
                    .transition(.opacity)

                UnboxAnimationView(
                    boxImageName: selectedBoxImageName,
                    characterImageName: selectedCharacterImageName,
                    characterName: selectedCharacterName,
                    rarityText: selectedRarityText,
                    mpsText: selectedMpsText
                ) {
                    showUnboxAnimation = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showUnboxAnimation)
    }
}

#Preview {
    StoreView(userViewModel: UserViewModel())
}
