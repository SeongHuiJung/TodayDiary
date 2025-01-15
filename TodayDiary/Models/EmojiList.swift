//
//  EmojiList.swift
//  TodayDiary
//
//  Created by 정성희 on 12/22/24.
//

import Foundation
import UIKit

func getEmoji(emojiNumber: Int) -> UIImage? {
    let emojiList = ["emptyEmoji",
                     "smile","smile2","happy","love",
                     "expect","calmn","sad","angry",
                     "blue","busy","sick","heart",
                     "star","coffee","flower","luck",
                     "rain","book","exclamation","question"]
    return UIImage(named: emojiList[emojiNumber])
}
