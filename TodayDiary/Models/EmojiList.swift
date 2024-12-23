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
    case 1: return UIImage(named: "maple")!
    case 2: return UIImage(named: "maple")!
    default:
        return UIImage(named: "emptyEmoji")
    }
}
