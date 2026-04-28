//
//  DailyTarotWidgetExtensionBundle.swift
//  DailyTarotWidgetExtension
//
//  Created by 卢颖 on 2026/3/15.
//

import WidgetKit
import SwiftUI

@main
struct DailyTarotWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        DailyTarotKeywordsWidget()
        DailyTarotMetricsWidget()
        DailyTarotSummaryWidget()
    }
}
