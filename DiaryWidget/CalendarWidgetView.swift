//
//  CalendarWidgetView.swift
//  TodayDiary
//
//  Created by 정성희 on 3/21/25.
//

import SwiftUI

struct CalendarWidgetView: View {
    var yearMonthdate: String
    var diaryData: [(Int,Int)]
    var date: Date
    var isLogin: Bool
    
    // 요일
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    private let emojiList = ["emptyEmoji",
                     "smile","smile2","happy","love",
                     "expect","calmn","sad","angry",
                     "blue","busy","sick","heart",
                     "star","coffee","flower","luck",
                     "rain","book","exclamation","question"]
    
    var body: some View {
        if !diaryData.isEmpty && isLogin {
            VStack {
                Spacer().frame(height: 15)
                Text(yearMonthdate)
                    .font(.custom(Font.bold.rawValue, size: 18))
                Spacer().frame(height: 15)
                
                
                HStack {
                    ForEach(0..<7) { index in
                        
                        VStack {
                            Text(daysOfWeek[index])
                                .font(.custom(Font.Light.rawValue, size: 13))
                                .foregroundColor(.secondary)
                            
                            if !diaryData.isEmpty {
                                // 저장된 일기가 있는 경우 이모지 표시
                                if diaryData[index].1 != 0 {
                                    Image(emojiList[diaryData[index].1])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 38, height: 38)
                                }
                                // 저장된 일기가 없는 경우, 해당 날짜 표시
                                else {
                                    let today = Calendar.current.component(.day, from: Date())
                                    // 미래인 내일~ 날짜는 회색처리
                                    if today < diaryData[index].0 &&  today + 10 > diaryData[index].0 {
                                        Text(String(diaryData[index].0))
                                            .font(.custom(Font.Medium.rawValue, size: 16))
                                            .foregroundColor(Color("color-widget-day-gray"))
                                            .fontWeight(.medium)
                                            .padding(.top, 10)
                                        Spacer().frame(height: 8)
                                    }
                                    // 과거~ 오늘까지의 날짜는 굵은 글씨 표시
                                    else {
                                        Text(String(diaryData[index].0))
                                            .font(.custom(Font.Medium.rawValue, size: 16))
                                            .fontWeight(.medium)
                                            .padding(.top, 10)
                                        Spacer().frame(height: 8)
                                    }
                                }
                            }
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                    }
                }
                .padding(.top, 3)
            }
        }
        else {
            Image("smile")
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
            Text("먼저 로그인 해주세요 :)")
                .font(.custom(Font.Medium.rawValue, size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color("color-widget-empty-text"))
        }
    }
}

#Preview {
    CalendarWidgetView(yearMonthdate: "", diaryData: [(Int, Int)](), date: Date(), isLogin: true)
}
