//
//  gameView.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/20/26.
//
// games that the user can play to earn money

import SwiftUI

struct FlappyBirdView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userViewModel: UserViewModel
    
    @State private var totalMoney: Int = 0
    @State private var pipeHasScored: Bool = false
    @State private var gameStarted = false
    @State private var birdY: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var isGameOver = false
    @State private var sessionMoney: Int = 0
    @State private var pipeX: CGFloat = 300
    @State private var gapCenterY: CGFloat = 0
    @State private var rotationAngle: Double = 0
    
    let pipeWidth: CGFloat = 60
    let gapSize: CGFloat = 160

    let gravity: CGFloat = 0.4
    let jumpStrength: CGFloat = -6
    let pipeSpeed: CGFloat = 3

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("FLAPPY BIRD").font(.custom("PressStart2P-Regular", size: 20))
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
            ZStack {

                Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.9)

                Rectangle()
                    .fill(Color(red: 0.6, green: 1.0, blue: 0.6))
                    .frame(height: 80)
                    .position(x: geo.size.width/2,
                              y: geo.size.height - 40)

                Image("HK")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(rotationAngle * 5))
                    .position(x: 80,
                              y: geo.size.height / 2 + birdY)
                Rectangle()
                    .fill(Color(red: 0.6, green: 1.0, blue: 0.6))
                    .frame(width: pipeWidth,
                           height: max(0, gapCenterY - gapSize/2))
                    .position(x: pipeX,
                              y: (gapCenterY - gapSize/2)/2)

                Rectangle()
                    .fill(Color(red: 0.6, green: 1.0, blue: 0.6))
                    .frame(width: pipeWidth,
                           height: max(0, geo.size.height - (gapCenterY + gapSize/2)))
                    .position(x: pipeX,
                              y: (gapCenterY + gapSize/2 + geo.size.height)/2)

                if !gameStarted {
                    VStack(spacing: 15) {
                        Text("FLAPPY BIRD")
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
                            .font(.custom("PressStart2P-Regular", size: 15))                            .bold()
                            .foregroundColor(.white).padding()
                        Button("RESTART?") {
                            resetGame(size: geo.size)
                        }
                        .foregroundColor(.white) .font(.custom("PressStart2P-Regular", size: 10))                            .bold()
                    }.padding()
                        .background(Color(red: 1.0, green: 0.75, blue: 0.8))
                }
            }
            .onTapGesture {
                if gameStarted && !isGameOver {
                    velocity = jumpStrength
                }
            }
        }
    }

    func startGame(size: CGSize) {
        resetPipes(size: size)
        sessionMoney = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            update(size: size)
        }
    }

    func resetGame(size: CGSize) {
        birdY = 0
        velocity = 0
        pipeX = size.width
        isGameOver = false
        gameStarted = false

        pipeHasScored = false
    }
    
    func resetPipes(size: CGSize) {
        pipeX = size.width + 100
        let minY = gapSize/2 + 80
        let maxY = size.height - gapSize/2 - 80
        gapCenterY = CGFloat.random(in: minY...maxY)
    }

    func update(size: CGSize) {
            guard gameStarted, !isGameOver else { return }

            velocity += gravity
            birdY += velocity
        rotationAngle += 0.5
            pipeX -= pipeSpeed

            if pipeX < 80 && !pipeHasScored {
                pipeHasScored = true

                DispatchQueue.main.async {
                    sessionMoney += 5
                    userViewModel.addMoneyFromGame(5)
                }
            }
            if pipeX < -50 {
                pipeX = size.width + 50
                pipeHasScored = false

                let minY = gapSize/2 + 80
                let maxY = size.height - gapSize/2 - 80
                gapCenterY = CGFloat.random(in: minY...maxY)
            }

            let birdRect = CGRect(x: 80,
                                  y: size.height/2 + birdY,
                                  width: 30,
                                  height: 30)

            let topPipeHeight = gapCenterY - gapSize/2
            let bottomPipeY = gapCenterY + gapSize/2

            let topPipeRect = CGRect(x: pipeX - pipeWidth/2,
                                     y: 0,
                                     width: pipeWidth,
                                     height: topPipeHeight)

            let bottomPipeRect = CGRect(x: pipeX - pipeWidth/2,
                                         y: bottomPipeY,
                                         width: pipeWidth,
                                         height: size.height - bottomPipeY)

            if birdRect.intersects(topPipeRect) ||
                birdRect.intersects(bottomPipeRect) ||
                birdRect.maxY > size.height - 80 {

                isGameOver = true
                timer?.invalidate()
            }
    }
}
#Preview {
    FlappyBirdView(userViewModel: UserViewModel())
}
