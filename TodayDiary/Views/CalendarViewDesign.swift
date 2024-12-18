//
//  CalendarViewDesign.swift
//  TodayDiary
//
//  Created by 정성희 on 12/13/24.
//

import Foundation
import FSCalendar

func setCalendarDesign(calendarView: FSCalendar!) {
    
    
    calendarView.locale = Locale(identifier: "ko_KR")
    calendarView.scrollEnabled = true   // 가능
    calendarView.scrollDirection = .horizontal  // 가로
    
    
    // 초기 날짜 지정
    calendarView.setCurrentPage(Date(), animated: true)
    calendarView.select(Date())
    
    // MARK: - 헤더 디자인
    // 기존의 헤더 가림 -> 커스텀 헤더뷰 디자인 예정
    calendarView.appearance.headerTitleColor = .clear
    calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
    calendarView.headerHeight = 66
    // 헤더 폰트 설정
    calendarView.appearance.headerTitleFont = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
    // 헤더의 날짜 포맷 설정
    calendarView.appearance.headerDateFormat = "YYYY년 MM월"
    // 헤더의 폰트 색상 설정
    calendarView.appearance.headerTitleColor = UIColor(red: 0.556, green: 0.424, blue: 0.424, alpha: 1)
    // 헤더 높이 설정
    calendarView.headerHeight = 60
    // 헤더 양 옆(전달 & 다음 달) 글씨 투명도
    calendarView.appearance.headerMinimumDissolvedAlpha = 0.0  // 0.0 = 안보이게 됩니다.
    
    
    // MARK: - 주간 디자인
    // Weekday 폰트 설정
    calendarView.appearance.weekdayFont = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    
    calendarView.appearance.weekdayTextColor = UIColor(red: 0.66, green: 0.581, blue: 0.582, alpha: 1)
    
    // 기존 calendar 선택시 나오는 색 투명화
    calendarView.appearance.selectionColor = .clear    // 기본 선택 배경 투명 -> 커스텀 셀 배경으로 표시
    
    
    // MARK: - 특정 일자 디자인
    calendarView.appearance.todayColor = .clear // 오늘 날짜 배경 원색
    calendarView.appearance.todaySelectionColor = .clear //오늘날짜 선택시 색상
    calendarView.appearance.selectionColor = .clear // 사용자가 선택한 날짜
    calendarView.appearance.titleSelectionColor = .clear // 선택한 날짜 글자색
}

