//
//  DiaryWidgetBundle.swift
//  DiaryWidget
//
//  Created by 정성희 on 3/21/25.
//

import WidgetKit
import SwiftUI

@main
struct DiaryWidgetBundle: WidgetBundle {
    var body: some Widget {
        DiaryWidget()
        DiaryWidgetControl()
    }
}
