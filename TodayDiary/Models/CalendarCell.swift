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
    private let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 원형 배경
    private let circleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1) // 원형 배경색
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    // 숫자 레이블
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 초기화
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        // 원형 배경 및 회색 뷰를 셀에 추가
        contentView.addSubview(grayView)
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
//            self.titleLabel.centerXAnchor.constraint(equalTo: circleBackgroundView.centerXAnchor),
//            self.titleLabel.centerYAnchor.constraint(equalTo: circleBackgroundView.centerYAnchor)
//            
            dayLabel.centerXAnchor.constraint(equalTo: circleBackgroundView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: circleBackgroundView.centerYAnchor)
        ])
        
        //회색 View 레이아웃 (하단부)
        NSLayoutConstraint.activate([
            grayView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            grayView.topAnchor.constraint(equalTo: circleBackgroundView.bottomAnchor, constant: 4),
            // 회색 뷰의 높이를 60%가 아니라, 원하는 크기로 설정 (예: contentView의 남은 공간)
            grayView.widthAnchor.constraint(equalToConstant: 44),
            grayView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // 숫자 업데이트
    func configure(with day: String) {
        dayLabel.text = day
    }
}
