//
//  LoadingViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 1/26/25.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 옵저버 등록
         NotificationCenter.default.addObserver(self, selector: #selector(showInfoPopView(_:)), name: NSNotification.Name("iCloudSetError"), object: nil)
    }
    @objc func showInfoPopView(_ notification: Notification) {
        let popText = """
iCloud 설정이 제대로 확인되지 않았어요!
기기 설정에서 iCloud 계정을 인증해 주세요
"""
        let popVC = InfoPopUpViewController()
        
        popVC.infoText = popText
        popVC.acceptBtnText = "확인"
        popVC.modalPresentationStyle = .overFullScreen
        
        self.present(popVC, animated: true, completion: nil)
    }
}
