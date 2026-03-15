//
//  MetricWatchWidgit.swift
//  MetricWatchWidgit
//
//  Created by Becket Bowes on 1/20/26.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        for minuteOffset in 0..<10 {
            let entryDate = calendar.date(byAdding: .minute, value: minuteOffset * 6, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let percentOfYear: CGFloat
    let hourRotation: CGFloat
    let minuteRotation: CGFloat
    let metricYear: String
    let metricDay: String
    let metricHour: String
    let metricMinute: String
    
    init(date: Date, configuration: ConfigurationAppIntent) {
        self.date = date
        self.configuration = configuration
        let cal = Calendar.current
        metricYear = String(cal.component(.year, from: date) + 3030)
        metricDay = String(format: "%03d", (cal.component(.dayOfYear, from: date) - 1))
        let metricMinutesToday: CGFloat = (CGFloat(cal.component(.hour, from: date) * 60) + CGFloat(cal.component(.minute, from: date))) / 1.44
        metricHour = String(Int(metricMinutesToday / 100))
        metricMinute = String(format: "%02d", Int(metricMinutesToday) % 100)
        percentOfYear = CGFloat(cal.component(.dayOfYear, from: date)) / CGFloat(cal.range(of: .day, in: .year, for: Date())!.count)
        hourRotation = (metricMinutesToday / 1000) * 360.0
        minuteRotation = (metricMinutesToday.truncatingRemainder(dividingBy: 100) / 100) * 360.0
    }
}

struct MetricWatchWidgitEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ComplicationView(entry: entry)
            .widgetURL(URL(string: "chronometrixt://main"))
    }
}

struct MetricWatchWidgit: Widget {
    let kind: String = "MetricWatchWidgit"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MetricWatchWidgitEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct MetricClockOnlyWidget: Widget {
    let kind: String = "MetricClockWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MetricClockOnlyComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct MetricCalendarOnlyWidget: Widget {
    let kind: String = "MetricCalendarWidgit"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MetricCalendarOnlyComplicationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
//    MetricWatchWidgit()
//    MetricClockOnlyWidget()
    MetricCalendarOnlyWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}    
