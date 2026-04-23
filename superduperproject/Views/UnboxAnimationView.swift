//
//  UnboxAnimationView.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/22/26.
//

import SwiftUI
import SpriteKit

struct UnboxAnimationView: View {
    let boxImageName: String
    let characterImageName: String
    let characterName: String
    let rarityText: String
    let mpsText: String
    let onDismiss: () -> Void

    @State private var scene: UnboxScene?
    @State private var showDetails = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .background(Color.clear)
                        .ignoresSafeArea()
                } else {
                    Color.clear.ignoresSafeArea()
                }

                if showDetails {
                    VStack(spacing: 0) {
                        Spacer().frame(height: geo.size.height * 0.58)
                        VStack(spacing: 12) {
                            Text(characterName)
                                .font(.custom("PressStart2P-Regular", size: 14))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)

                            Text("RARITY: \(rarityText)")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.black)

                            Text("MPS: $\(mpsText)")
                                .font(.custom("PressStart2P-Regular", size: 10))
                                .foregroundColor(.black)

                            Button("DISMISS") {
                                onDismiss()
                            }
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.92))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                                )
                        )
                        .padding(.horizontal, 12)
                        Spacer()
                    }
                }
            }
            .onAppear {
                guard scene == nil else { return }
                scene = UnboxScene(
                    size: geo.size,
                    boxImageName: boxImageName,
                    characterImageName: characterImageName
                ) {
                    showDetails = true
                }
            }
        }
    }
}

#Preview {
    UnboxAnimationView(
        boxImageName: "spidermanbox",
        characterImageName: "miles",
        characterName: "Miles Morales",
        rarityText: "LEGENDARY",
        mpsText: "8.0",
        onDismiss: {}
    )
}
