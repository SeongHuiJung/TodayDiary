//
//  CalendarCell.swift
//  TodayDiary
//
//  Created by 정성희 on 12/16/24.
//

import UIKit
import FSCalendar

import UIKit
import FSCalendar

class CalendarCell: FSCalendarCell {
    
    // 하단 회색 View 추가
    private let emotionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 0.971, blue: 0.96, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 원형 배경
    private let circleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    // 숫자 레이블
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 13)
        label.textColor = UIColor(red: 0.564, green: 0.477, blue: 0.477, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 초기화
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        // 원형 배경 및 회색 뷰를 셀에 추가
        contentView.addSubview(emotionView)
        contentView.addSubview(circleBackgroundView)
        circleBackgroundView.addSubview(dayLabel)
        
        setupLayout()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 레이아웃 설정
    private func setupLayout() {
        // 원형 배경 레이아웃 (상단 중앙)
        NSLayoutConstraint.activate([
            circleBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            circleBackgroundView.widthAnchor.constraint(equalToConstant: 20),
            circleBackgroundView.heightAnchor.constraint(equalToConstant: 20)
        ])
        circleBackgroundView.layer.cornerRadius = 10 // 원형으로 만듦
        
        // 숫자 레이블 (원형 중앙)
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: circleBackgroundView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: circleBackgroundView.centerYAnchor)
        ])
        
        //회색 View 레이아웃 (하단부)
        NSLayoutConstraint.activate([
            emotionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emotionView.topAnchor.constraint(equalTo: circleBackgroundView.bottomAnchor, constant: 4),
            emotionView.widthAnchor.constraint(equalToConstant: 44),
            emotionView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // 숫자 업데이트
    func configure(with day: String) {
        dayLabel.text = day
    }
    
    // cell 재사용을 위한 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.layer.opacity = 1
        circleBackgroundView.backgroundColor = .clear
        dayLabel.textColor = UIColor(red: 0.564, green: 0.477, blue: 0.477, alpha: 1)
    }
    
    func setCalendarCellDesign(monthPosition: FSCalendarMonthPosition, date: Date) {
        // 일기 데이터가 있는 경우 그림으로 표기
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        // 오늘인 경우 동그라미 표기, 일자 글씨 색 변경
        if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
            circleBackgroundView.backgroundColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
            dayLabel.textColor = UIColor(red: 1, green: 0.971, blue: 0.96, alpha: 1)
        }
        
        // 이번달 날짜가 아닌 경우 뿌옇게 표기
        if monthPosition == .next || monthPosition == .previous {
            dayLabel.layer.opacity = 0.5
        }
    }
}
