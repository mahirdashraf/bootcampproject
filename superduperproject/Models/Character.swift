//
//  Characters.swift
//  Characters
//
//  Created by Ashley Ni on 4/6/26.
//
import Foundation

enum Rarity: String, Codable, CaseIterable, Hashable {
    case common
    case uncommon
    case rare
    case legendary

    var dropWeight: Double {
        switch self {
        case .common: return 60
        case .uncommon: return 25
        case .rare: return 10
        case .legendary: return 5
        }
    }
}

enum Universe: String, Codable, CaseIterable, Hashable {
    case spiderverse
    case hellokittyverse
    case marioverse
}

struct ItemModel: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var rarity: Rarity
    var universe: Universe

    var baseEarningRate: Double
    var weight: Double?

    var imageName: String
    var spriteFileName: String?
}
