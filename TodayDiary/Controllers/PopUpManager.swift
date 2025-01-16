//
//  PopUpManager.swift
//  TodayDiary
//
//  Created by 정성희 on 1/16/25.
//

import Foundation
class PopUpManager {
    static let shared = PopUpManager()
    private init() {}
    
    private var popupQueue: [() -> Void] = []
    private var isPresentingPopup = false
    
    // 팝업 뷰 추가
    func addPopup(popupTask: @escaping () -> Void) {
        popupQueue.append(popupTask)
        showNextPopup() // 바로 팝업 띄우기 시도
    }
    
    // 현재 띄워진 팝업이 없고, 큐에 팝업이 있는 경우에만 팝업 띄움
    private func showNextPopup() {
        guard !isPresentingPopup, let nextPopupTask = popupQueue.first else { return }
        
        isPresentingPopup = true
        popupQueue.removeFirst() // 지금 띄운 팝업 뷰는 큐에서 삭제
        nextPopupTask() // 팝업 띄우는 클로저 실행
    }
    
    // 팝업 뷰 닫을 때 호출
    func popupDidDismiss() {
        isPresentingPopup = false
        showNextPopup() // 다음 팝업 뷰 띄우기 시도
    }
}
