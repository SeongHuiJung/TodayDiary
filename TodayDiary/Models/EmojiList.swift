//
//  EmojiList.swift
//  TodayDiary
//
//  Created by 정성희 on 12/22/24.
//

import Foundation
import UIKit

func getEmoji(emoji: Int) -> UIImage? {
    switch emoji {
    case 1: return UIImage(named: "smile")!
    case 2: return UIImage(named: "smile2")!
    case 3: return UIImage(named: "happy")!
    case 4: return UIImage(named: "love")!
    case 5: return UIImage(named: "expect")!
    case 6: return UIImage(named: "calmn")!
    case 7: return UIImage(named: "sad")!
    case 8: return UIImage(named: "angry")!
    case 9: return UIImage(named: "blue")!
    case 10: return UIImage(named: "busy")!
    case 11: return UIImage(named: "sick")!
    case 12: return UIImage(named: "heart")!
    case 13: return UIImage(named: "star")!
    case 14: return UIImage(named: "coffee")!
    case 15: return UIImage(named: "flower")!
    case 16: return UIImage(named: "luck")!
    case 17: return UIImage(named: "rain")!
    case 18: return UIImage(named: "book")!
    case 19: return UIImage(named: "exclamation")!
    case 20: return UIImage(named: "question")!
    
    default:
        return UIImage(named: "emptyEmoji")
    }
}
