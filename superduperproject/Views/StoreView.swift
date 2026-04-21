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
    @State private var lastResult: UserViewModel.OpenBoxResult?
    @State private var errorMessage: String?
    
    private var blindBoxes: [BlindBoxModel] {
        GameCatalog.blindBoxes
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(blindBoxes, id: \.id) { box in
                        VStack(spacing: 10) {
                            Image(systemName: "box.2")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 120)
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
                                    lastResult = result
                                    showResult = true
                                    errorMessage = nil
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
        .alert("Result", isPresented: $showResult) {
            Button("OK") {
                showResult = false
                lastResult = nil
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            } else if let result = lastResult {
                let character = GameCatalog.itemCatalog[result.wonItemID]
                let mpsText = character.map { String(format: "%.1f", $0.baseEarningRate) } ?? "0"
                Text("You got: \(result.wonItemID.uppercased())\nRarity: \(result.wonItemRarity.rawValue.uppercased())\nMPS: $\(mpsText)\nNew Balance: $\(Int(result.newBalance))")
            }
        }
    }
}

#Preview {
    StoreView(userViewModel: UserViewModel())
}
