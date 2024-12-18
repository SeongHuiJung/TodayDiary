//
//  WriteDiaryViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/17/24.
//

import UIKit

class WriteDiaryViewController: UIViewController {

    var dateString: String?
    
    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = dateString ?? "error"
    }

    @IBAction func tappedBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
