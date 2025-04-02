//
//  DiaryWidget.swift
//  DiaryWidget
//
//  Created by 정성희 on 3/21/25.
//

import WidgetKit
import SwiftUI
import CoreData

// 위젯을 업데이트 할 시기를 WidgetKit에 알리는 역할
struct Provider: TimelineProvider {
    
    // 데이터를 불러오기 전(getSnapshot)에 보여줄 placeholder
    // 위젯을 처음 생성하는 경우에만, 위젯 갤러리에 나타낼 임시 데이터. 스켈레톤 UI 와 유사
    func placeholder(in context: Context) -> SimpleEntry {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 설정
        dateFormatter.dateFormat = "yyyy년 M월"
        let dateString = dateFormatter.string(from: Date())
        
        let weekDayList = getWeekDayList()
        
        return SimpleEntry(date: Date(), yearMonthData: dateString, diaryData: weekDayList, isLogin: true)
    }
    
    // 위젯 갤러리에서 보여질 부분
    // 위젯 갤러리에서 스켈레톤 ui 이후에 보여줄 로드된 실제 데이터를 표출
    // 위젯 갤러리에서 위젯을 고를 때 보이는 샘플 데이터를 보여줄때 해당 메소드 호출
    // API를 통해서 데이터를 fetch하여 보여줄때 딜레이가 있는 경우 여기서 샘플 데이터를 하드코딩해서 보여주는 작업도 가능
    // context.isPreview가 true인 경우 위젯 갤러리에 위젯이 표출되는 상태
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 설정
        dateFormatter.dateFormat = "yyyy년 M월"
        let dateString = dateFormatter.string(from: Date())
        
        let weekDayList = getWeekDayList()
        
        let entry = SimpleEntry(date: Date(), yearMonthData: dateString, diaryData: weekDayList, isLogin: true)
        completion(entry)
    }

    // 위젯 내용 업데이트
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let nextUpdateDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let entry = SimpleEntry(date: nextUpdateDate, yearMonthData: WidgetData.shared.yearMonthdate, diaryData: WidgetData.shared.diaryData, isLogin: WidgetData.shared.isLogin)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func getWeekDayList() -> [(Int,Int)] {
        let calendar = Calendar.current
        
        let dateComponents = CoreDataManager.shared.loadWeekDay()
        let startComponent = dateComponents.0
        let endComponent = dateComponents.1
        
        guard let startDate = calendar.date(from: startComponent) else { return [] }
        guard let endDate = calendar.date(from: endComponent) else { return [] }
        
        var dayNumbers: [(Int,Int)] = []
        var currentDate = startDate
        while currentDate <= endDate {
            let day = calendar.component(.day, from: currentDate)
            dayNumbers.append((day,0))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dayNumbers
    }
}

// 위젯에 나타낼 데이터 구조
// TimelineEntry: 위젯을 표시할 Date를 정하고, 그 Data에 표시할 데이터를 나타냄
struct SimpleEntry: TimelineEntry {
    var date: Date
    var yearMonthData: String
    var diaryData: [(Int,Int)]
    var isLogin: Bool
}

// 위젯 뷰 디자인 바디
struct DiaryWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        CalendarWidgetView(yearMonthdate: entry.yearMonthData, diaryData: entry.diaryData, date: entry.date, isLogin: entry.isLogin)
    }
}

struct DiaryWidget: Widget {
    let kind: String = "DiaryWidget"
    
    // body 안에 사용하는 Configuration
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DiaryWidgetEntryView(entry: entry) // 위젯에 표출될 뷰
                    .containerBackground(.fill.quinary, for: .widget)
            } else {
                DiaryWidgetEntryView(entry: entry) // 위젯에 표출될 뷰
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("토끼의 일기")
        .description("이번 주에 기록한 일기를 한눈에 볼 수 있어요")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    DiaryWidget()
} timeline: {
    SimpleEntry(date: Date(), yearMonthData: "", diaryData: [(Int, Int)](), isLogin: true)
}
