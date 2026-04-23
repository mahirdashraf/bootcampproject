//
//  DinoGame.swift
//  superduperproject
//
//  Created by Juliana Martinez on 4/23/26.
//

import SwiftUI

struct DinoGameView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userViewModel: UserViewModel

    @State private var gameStarted = false
    @State private var isGameOver = false
    @State private var dinoY: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var isOnGround = true
    @State private var timer: Timer? = nil
    @State private var sessionMoney: Int = 0
    @State private var score: Int = 0
    @State private var cactusX: CGFloat = 400
    @State private var cactusX2: CGFloat = 700
    @State private var groundOffset: CGFloat = 0
    @State private var cactusHasScored: Bool = false
    @State private var cactusHasScored2: Bool = false

    let gravity: CGFloat = 0.5
    let jumpStrength: CGFloat = -10
    let gameSpeed: CGFloat = 4
    let groundY: CGFloat = 0
    let dinoWidth: CGFloat = 44
    let dinoHeight: CGFloat = 44
    let cactusWidth: CGFloat = 30
    let cactusHeight: CGFloat = 58

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("DINO RUN")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(10)

                ZStack {
                    GameCanvas
                }
                .frame(width: 320, height: 550)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 6)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack {
                    Text("Session Earnings: $\(sessionMoney)")
                        .font(.custom("PressStart2P-Regular", size: 15))
                        .foregroundColor(.white)
                        .padding(10)
                    Text("Total Balance: $\(Int(userViewModel.player.totalMoney))")
                        .font(.custom("PressStart2P-Regular", size: 15))
                        .foregroundColor(.white)
                }
                .frame(width: 340, alignment: .center)
                .padding(.horizontal)
            }

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("BACK")
                        }
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var GameCanvas: some View {
        GeometryReader { geo in
            let groundLevel = geo.size.height - 80
            let dinoX: CGFloat = 60

            ZStack {
                Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.9)
                ForEach(0..<5) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 80, height: 2)
                        .position(
                            x: (CGFloat(i) * 80 + groundOffset).truncatingRemainder(dividingBy: geo.size.width + 80) - 40,
                            y: groundLevel + 2
                        )
                }
                Rectangle()
                    .fill(Color(red: 0.5, green: 0.4, blue: 0.3))
                    .frame(height: 4)
                    .position(x: geo.size.width / 2, y: groundLevel)
                Rectangle()
                    .fill(Color(red: 0.45, green: 0.85, blue: 0.45))
                    .frame(height: 80)
                    .position(x: geo.size.width / 2, y: geo.size.height - 40)
                Image("peter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .scaleEffect(x: -1, y: 1)
                    .position(x: dinoX, y: groundLevel - 22 + dinoY)
                CactusView(height: cactusHeight)
                    .position(x: cactusX, y: groundLevel - cactusHeight / 2)
                CactusView(height: cactusHeight - 10, small: true)
                    .position(x: cactusX2, y: groundLevel - (cactusHeight - 10) / 2)
                if !gameStarted {
                    VStack(spacing: 15) {
                        Text("DINO RUN")
                            .font(.custom("PressStart2P-Regular", size: 14))
                            .foregroundColor(.white)
                        Button("START") {
                            startGame(size: geo.size)
                            gameStarted = true
                        }
                        .font(.custom("PressStart2P-Regular", size: 12))
                        .padding()
                        .background(Color(red: 1.0, green: 0.6, blue: 0.6))
                        .foregroundColor(.white)
                    }
                }
                if isGameOver && gameStarted {
                    VStack {
                        Text("GAME OVER")
                            .font(.custom("PressStart2P-Regular", size: 15))
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                        Button("RESTART?") {
                            resetGame(size: geo.size)
                        }
                        .foregroundColor(.white)
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .bold()
                    }
                    .padding()
                    .background(Color(red: 1.0, green: 0.75, blue: 0.8))
                }
            }
            .onTapGesture {
                if gameStarted && !isGameOver && isOnGround {
                    velocity = jumpStrength
                    isOnGround = false
                }
            }
        }
    }

    func startGame(size: CGSize) {
        sessionMoney = 0
        score = 0
        dinoY = 0
        velocity = 0
        cactusX = size.width + 50
        cactusX2 = size.width + 250
        cactusHasScored = false
        cactusHasScored2 = false
        isOnGround = true
        isGameOver = false

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            update(size: size)
        }
    }

    func resetGame(size: CGSize) {
        isGameOver = false
        gameStarted = false
        dinoY = 0
        velocity = 0
        isOnGround = true
        score = 0
        cactusX = size.width + 50
        cactusX2 = size.width + 250
        cactusHasScored = false
        cactusHasScored2 = false
        groundOffset = 0
    }

    func update(size: CGSize) {
        guard gameStarted, !isGameOver else { return }

        let groundLevel = size.height - 80

        // Physics
        velocity += gravity
        dinoY += velocity
        groundOffset -= gameSpeed

        // Clamp to ground
        if dinoY >= 0 {
            dinoY = 0
            velocity = 0
            isOnGround = true
        }

        // Move cactuses
        cactusX -= gameSpeed
        cactusX2 -= gameSpeed

        // Score per cactus passed
        let dinoX: CGFloat = 60
        if cactusX < dinoX && !cactusHasScored {
            cactusHasScored = true
            score += 1
            sessionMoney += 5
            userViewModel.addMoneyFromGame(5)
        }
        if cactusX2 < dinoX && !cactusHasScored2 {
            cactusHasScored2 = true
            score += 1
            sessionMoney += 5
            userViewModel.addMoneyFromGame(5)
        }

        // Reset cactuses
        if cactusX < -30 {
            cactusX = size.width + CGFloat.random(in: 50...150)
            cactusHasScored = false
        }
        if cactusX2 < -30 {
            cactusX2 = size.width + CGFloat.random(in: 50...150)
            cactusHasScored2 = false
        }

        // Collision detection
        let dinoRect = CGRect(
            x: dinoX - 16,
            y: groundLevel - dinoHeight + dinoY,
            width: 32,
            height: dinoHeight
        )
        let cactus1Rect = CGRect(
            x: cactusX - cactusWidth / 2,
            y: groundLevel - cactusHeight,
            width: cactusWidth,
            height: cactusHeight
        )
        let cactus2Rect = CGRect(
            x: cactusX2 - cactusWidth / 2,
            y: groundLevel - (cactusHeight - 10),
            width: cactusWidth,
            height: cactusHeight - 10
        )

        if dinoRect.intersects(cactus1Rect) || dinoRect.intersects(cactus2Rect) {
            isGameOver = true
            timer?.invalidate()
        }
    }
}

struct CactusView: View {
    let height: CGFloat
    var small: Bool = false

    var body: some View {
        Canvas { context, size in
            let p: CGFloat = small ? 3.2 : 3.8
            let color = Color(red: 0.22, green: 0.51, blue: 0.22)

            let pixels: [(Int, Int)] = [
                // Top spike
                (3,0),(4,0),
                (3,1),(4,1),
                (3,2),(4,2),
                // Left arm
                (1,3),(2,3),(3,4),(4,3),
                (1,4),(3,4),(4,4),
                (1,5),(2,5),(3,5),(4,5),
                               (3,6),(4,6),
                // Right arm
                (3,7),(4,7),(5,7),(6,7),(7,7),
                (3,8),(4,8),      (5,8),(6,8),(7,8),
                (3,9),(4,9),            (6,9),(7,9),
                (3,10),(4,10),(5,10),(6,10),(7,10),
                // Lower trunk
                (3,11),(4,11),
                (3,12),(4,12),
                (3,13),(4,13),
                // Base
                (2,14),(3,14),(4,14),(5,14),
            ]

            for (col, row) in pixels {
                let rect = CGRect(
                    x: CGFloat(col) * p,
                    y: CGFloat(row) * p,
                    width: p, height: p
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: small ? 34 : 40, height: height)
    }
}

#Preview {
    DinoGameView(userViewModel: UserViewModel())
}
