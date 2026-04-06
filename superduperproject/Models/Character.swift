//
//  Characters.swift
//  Characters
//
//  Created by Ashley Ni on 4/6/26.
//

enum Rarity {
    case common, uncommon, rare, legendary
}
enum CharacterVerse {
    case spiderVerse, helloKitty, legoVerse
}


struct Item {
    var rarity: Rarity
    var moneyPerSecond: Double
    var name: String
    var characterVerse: CharacterVerse
}
