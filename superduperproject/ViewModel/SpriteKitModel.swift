//
//  SpriteKitModel.swift
//  superduperproject
//
//  Created by Ashley Ni on 4/14/26.
//
import SpriteKit

final class UnboxScene: SKScene {
    private let boxContainer = SKNode()
    private let sparkleLayer = SKNode()
    private let boxClosed: SKSpriteNode
    private let boxOpen: SKSpriteNode
    private let character: SKSpriteNode
    private let characterGlow: SKSpriteNode
    private let characterGlowColor: SKColor
    private let onFinished: () -> Void
    private let tapSoundFileName: String?
    private let revealSoundFileName: String?

    private var ambientParticles: SKEmitterNode?
    private var tapCount = 0
    private var isAnimatingTap = false
    private var didReveal = false
    
    init(
        size: CGSize,
        boxImageName: String,
        characterImageName: String,
        characterGlowColor: SKColor,
        onFinished: @escaping () -> Void
    ){
        self.boxClosed = SKSpriteNode(imageNamed: boxImageName)
        self.boxOpen = SKSpriteNode(imageNamed: boxImageName)
        self.character = SKSpriteNode(imageNamed: characterImageName)
        self.characterGlow = SKSpriteNode(texture: self.character.texture)
        self.characterGlow.size = self.character.size
        self.characterGlowColor = characterGlowColor
        self.tapSoundFileName = UnboxScene.availableSoundFile(
            ["unbox-tap.wav", "tap.wav", "box_tap.wav", "click.wav", "tap.mp3"]
        )
        self.revealSoundFileName = UnboxScene.availableSoundFile(
            ["unbox-reveal.wav", "unbox.wav", "box_open.wav", "reveal.wav", "unbox.mp3"]
        )
        self.onFinished = onFinished
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let boxMaxWidth = size.width * 0.42
        if boxClosed.size.width > 0 {
            let boxScale = boxMaxWidth / boxClosed.size.width
            boxClosed.setScale(boxScale)
            boxOpen.setScale(boxScale)
        }
        if character.size.width > 0 {
            let characterScale = (size.width * 0.45) / character.size.width
            character.setScale(characterScale)
            characterGlow.setScale(characterScale * 1.12)
        }

        boxContainer.position = center
        boxClosed.position = .zero
        boxOpen.position = CGPoint(x: 0, y: -boxClosed.size.height * 0.08)
        boxOpen.alpha = 0
        boxOpen.yScale = boxClosed.yScale
        boxOpen.color = .white
        boxOpen.colorBlendFactor = 0.18

        character.position = CGPoint(x: center.x, y: center.y - boxClosed.size.height * 0.2)
        character.alpha = 0
        characterGlow.position = character.position
        characterGlow.alpha = 0
        characterGlow.color = characterGlowColor
        characterGlow.colorBlendFactor = 1
        characterGlow.blendMode = .add
        characterGlow.zPosition = character.zPosition - 1

        addChild(boxContainer)
        boxContainer.addChild(boxClosed)
        boxContainer.addChild(boxOpen)
        addChild(characterGlow)
        addChild(character)
        addChild(sparkleLayer)
        sparkleLayer.zPosition = 8

        let glow = SKShapeNode(circleOfRadius: boxClosed.size.width * 0.38)
        glow.fillColor = SKColor(red: 1.0, green: 0.88, blue: 0.45, alpha: 0.18)
        glow.strokeColor = .clear
        glow.zPosition = -2
        boxContainer.addChild(glow)
        glow.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.28, duration: 0.6),
            .fadeAlpha(to: 0.12, duration: 0.6)
        ])))

        let ambient = makeAmbientParticles()
        ambientParticles = ambient
        boxContainer.addChild(ambient)
        startCuteSparkles()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didReveal, !isAnimatingTap else { return }
        isAnimatingTap = true
        tapCount += 1
        playSoundIfAvailable(tapSoundFileName)
        pulseAmbientParticles()

        boxContainer.run(boxShakeAction) {
            if self.tapCount >= 3 {
                self.runFinalShakeThenReveal()
            } else {
                self.isAnimatingTap = false
            }
        }
    }

    private var boxShakeAction: SKAction {
        .sequence([
            .rotate(toAngle: 0.08, duration: 0.06),
            .rotate(toAngle: -0.08, duration: 0.06),
            .rotate(toAngle: 0, duration: 0.04)
        ])
    }

    private func runFinalShakeThenReveal() {
        let anticipationShake = SKAction.repeat(
            .sequence([
                boxShakeAction,
                .run { self.pulseAmbientParticles() }
            ]),
            count: 10
        )
        let slowZoomIn = SKAction.scale(by: 1.18, duration: 1.6)
        boxContainer.run(.sequence([
            .group([anticipationShake, slowZoomIn]),
            .run { self.revealCharacter() }
        ]))
    }

    private func revealCharacter() {
        didReveal = true
        playSoundIfAvailable(revealSoundFileName)
        ambientParticles?.particleBirthRate = 0
        sparkleLayer.removeAction(forKey: "spawnSparkles")
        spawnRevealBurst(at: boxContainer.position)

        let showOpenedBox = SKAction.run {
            self.boxClosed.alpha = 0
            self.boxOpen.alpha = 1
        }
        let explosionPulse = SKAction.group([
            .scale(by: 1.3, duration: 0.22),
            .fadeOut(withDuration: 0.22)
        ])
        let hideBox = SKAction.run {
            self.boxContainer.alpha = 0
        }
        let popOut = SKAction.group([
            .moveBy(x: 0, y: 180, duration: 0.35),
            .fadeIn(withDuration: 0.2)
        ])
        let glowPopIn = SKAction.sequence([
            .fadeAlpha(to: 0.4, duration: 0.25),
            .repeatForever(
                .sequence([
                    .fadeAlpha(to: 0.65, duration: 0.35),
                    .fadeAlpha(to: 0.35, duration: 0.35)
                ])
            )
        ])
        let done = SKAction.run {
            self.isAnimatingTap = false
            self.onFinished()
        }
        boxContainer.run(.sequence([
            showOpenedBox,
            .wait(forDuration: 0.05),
            .run { self.spawnRevealBurst(at: self.boxContainer.position) },
            explosionPulse,
            hideBox,
            .wait(forDuration: 0.08),
            .run {
                self.spawnRevealBurst(at: self.character.position)
            },
            .wait(forDuration: 0.05),
            .run {
                self.character.run(popOut)
                self.characterGlow.run(.group([
                    .moveBy(x: 0, y: 180, duration: 0.35),
                    glowPopIn
                ]))
            },
            .wait(forDuration: 0.45),
            done
        ]))
    }

    private func makeAmbientParticles() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 55
        emitter.numParticlesToEmit = 0
        emitter.particleLifetime = 1.4
        emitter.particleLifetimeRange = 0.45
        emitter.particleSpeed = 22
        emitter.particleSpeedRange = 32
        emitter.emissionAngleRange = .pi * 2
        emitter.particlePositionRange = CGVector(dx: boxClosed.size.width * 1.15, dy: boxClosed.size.height * 0.9)
        emitter.particleScale = 0.12
        emitter.particleScaleRange = 0.07
        emitter.particleAlpha = 0.85
        emitter.particleAlphaRange = 0.22
        emitter.particleAlphaSpeed = -0.5
        emitter.particleColor = SKColor(red: 1.0, green: 0.76, blue: 0.86, alpha: 1.0)
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .alpha
        emitter.zPosition = 3
        return emitter
    }

    private func pulseAmbientParticles() {
        guard let ambientParticles else { return }
        let baseRate = ambientParticles.particleBirthRate
        ambientParticles.particleBirthRate = baseRate + 95
        ambientParticles.run(.sequence([
            .wait(forDuration: 0.12),
            .run { [weak ambientParticles] in
                ambientParticles?.particleBirthRate = baseRate
            }
        ]))
    }

    private func startCuteSparkles() {
        sparkleLayer.run(
            .repeatForever(
                .sequence([
                    .run { [weak self] in self?.spawnFloatingSparkle() },
                    .wait(forDuration: 0.08)
                ])
            ),
            withKey: "spawnSparkles"
        )
    }

    private func spawnFloatingSparkle() {
        let shape: SKShapeNode
        if Bool.random() {
            shape = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
        } else {
            let side = CGFloat.random(in: 6...10)
            let rect = CGRect(x: -side / 2, y: -side / 2, width: side, height: side)
            shape = SKShapeNode(rect: rect, cornerRadius: side * 0.35)
            shape.zRotation = CGFloat.random(in: -0.5...0.5)
        }

        shape.position = CGPoint(
            x: boxContainer.position.x + CGFloat.random(in: -boxClosed.size.width * 0.7...boxClosed.size.width * 0.7),
            y: boxContainer.position.y + CGFloat.random(in: -boxClosed.size.height * 0.45...boxClosed.size.height * 0.45)
        )
        shape.fillColor = randomPastelColor()
        shape.strokeColor = .clear
        shape.alpha = CGFloat.random(in: 0.65...0.95)
        sparkleLayer.addChild(shape)

        let driftX = CGFloat.random(in: -20...20)
        let driftY = CGFloat.random(in: 25...55)
        let duration = Double.random(in: 0.45...0.95)
        shape.run(
            .sequence([
                .group([
                    .moveBy(x: driftX, y: driftY, duration: duration),
                    .fadeOut(withDuration: duration),
                    .scale(to: CGFloat.random(in: 0.5...1.4), duration: duration)
                ]),
                .removeFromParent()
            ])
        )
    }

    private func randomPastelColor() -> SKColor {
        let palette: [SKColor] = [
            SKColor(red: 1.0, green: 0.72, blue: 0.86, alpha: 1),  // pink
            SKColor(red: 0.73, green: 0.85, blue: 1.0, alpha: 1),  // blue
            SKColor(red: 0.78, green: 1.0, blue: 0.78, alpha: 1),  // mint
            SKColor(red: 1.0, green: 0.92, blue: 0.62, alpha: 1),  // yellow
            SKColor(red: 0.9, green: 0.78, blue: 1.0, alpha: 1)    // lavender
        ]
        return palette.randomElement() ?? .white
    }

    private func spawnRevealBurst(at point: CGPoint) {
        let burst = SKEmitterNode()
        burst.position = point
        burst.zPosition = 10
        burst.numParticlesToEmit = 120
        burst.particleBirthRate = 240
        burst.particleLifetime = 0.8
        burst.particleLifetimeRange = 0.2
        burst.particleSpeed = 170
        burst.particleSpeedRange = 60
        burst.emissionAngleRange = .pi * 2
        burst.particleScale = 0.08
        burst.particleScaleRange = 0.05
        burst.particleScaleSpeed = -0.07
        burst.particleAlpha = 0.9
        burst.particleAlphaSpeed = -1.1
        burst.particleBlendMode = .add
        burst.particleColor = SKColor(red: 1.0, green: 0.86, blue: 0.3, alpha: 1.0)
        burst.particleColorBlendFactor = 1
        addChild(burst)
        burst.run(.sequence([.wait(forDuration: 1.2), .removeFromParent()]))
    }

    private func playSoundIfAvailable(_ fileName: String?) {
        guard let fileName else { return }
        run(.playSoundFileNamed(fileName, waitForCompletion: false))
    }

    private static func availableSoundFile(_ candidates: [String]) -> String? {
        for file in candidates {
            let parts = file.split(separator: ".", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            if Bundle.main.url(forResource: parts[0], withExtension: parts[1]) != nil {
                return file
            }
        }
        return nil
    }
}
