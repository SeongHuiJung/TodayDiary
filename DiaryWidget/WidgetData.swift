//
//  WidgetData.swift
//  TodayDiary
//
//  Created by 정성희 on 3/31/25.
//

import Foundation
class WidgetData {
    static let shared = WidgetData()
    private let defaults = UserDefaults(suiteName: "group.jayseong.TodayDiary")
    
    private let emojiIndex = ["emojiSUN","emojiMON",
                      "emojiTUE", "emojiWED",
                      "emojiTHU", "emojiFRI",
                      "emojiSAT"]
    private let dateIndex = ["dateSUN","dateMON",
                      "dateTUE", "dateWED",
                      "dateTHU", "dateFRI",
                      "dateSAT"]
    
    var diaryData: [(Int,Int)] {
        get {
            var result = [(Int,Int)]()
            for index in 0..<7 {
                if defaults?.integer(forKey: dateIndex[index]) != 0 {
                    let date = defaults?.integer(forKey: dateIndex[index]) ?? 0
                    let emoji = defaults?.integer(forKey: emojiIndex[index]) ?? 0
                    result.append((date,emoji))
                }
            }
            return result
        }
        set {
            for index in 0..<7 {
                defaults?.set(newValue[index].0, forKey: dateIndex[index])
                defaults?.set(newValue[index].1, forKey: emojiIndex[index])
            }
        }
    }
    
    var yearMonthdate: String {
        get {
            defaults?.string(forKey: "yearMonthdate") ?? ""
        }
        set {
            defaults?.set(newValue, forKey: "yearMonthdate")
        }
    }
    
    var isLogin: Bool {
        get {
            defaults?.bool(forKey: "isLogin") ?? false
        }
        set {
            defaults?.set(newValue, forKey: "isLogin")
        }
    }
}
