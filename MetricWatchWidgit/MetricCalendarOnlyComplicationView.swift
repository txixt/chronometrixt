//
//  MetricCalendarOnlyComplicationView.swift
//  MetricWatchWidgitExtension
//
//  Created by Becket Bowes on 1/25/26.
//

import SwiftUI
import WidgetKit

struct MetricCalendarOnlyComplicationView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall: CalendarSystemSmallView(entry: entry)
        case .systemMedium: CalendarSystemMediumView(entry: entry)
        case .systemLarge: CalendarSystemLargeView(entry: entry)
        case .systemExtraLarge: CalendarSystemExtraLargeView(entry: entry)
        case .systemExtraLargePortrait: CalendarSystemExtraLargeProtraitView(entry: entry)
        case .accessoryCorner: CalendarAccessoryCornerView(entry: entry)
        case .accessoryCircular: CalendarAccessoryCircularView(entry: entry)
        case .accessoryRectangular: CalendarAccessoryRectangularView(entry: entry)
        case .accessoryInline: CalendarAccessoryInlineView(entry: entry)
        default: CalendarSystemSmallView(entry: entry)
        }
    }
}

struct CalendarSystemSmallView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestCalendar(entry: entry, scale: 0.25)
        }
    }
}

struct CalendarSystemMediumView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestCalendar(entry: entry, scale: 0.3)
        }
    }
}

struct CalendarSystemLargeView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestCalendar(entry: entry, scale: 0.35)
        }
    }
}

struct CalendarSystemExtraLargeView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestCalendar(entry: entry, scale: 0.4)
        }
    }
}

struct CalendarSystemExtraLargeProtraitView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricIcon(entry: entry, scale: 0.3)
                SimpleMetricText(entry: entry, scale: 0.55)
            }
        }
    }
}

struct CalendarAccessoryCornerView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestCalendar(entry: entry, scale: 0.3)
                .widgetLabel {
                    Text("\(entry.metricYear)•\(entry.metricDay)")
                }
        }
    }
}

struct CalendarAccessoryCircularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        SimplestCalendar(entry: entry, scale: 0.4)
    }
}

struct CalendarAccessoryRectangularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            HStack {
                SimpleMetricIcon(entry: entry, scale: 0.4)
                SimpleMetricText(entry: entry, scale: 0.45)
            }
        }
    }
}

struct CalendarAccessoryInlineView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricText(entry: entry, scale: 0.55)
            }
        }
    }
}

struct CalendarSimpleMetricIcon: View {
    var entry: SimpleEntry
    var scale: CGFloat = 0.15
    
    var body: some View {
        HStack {
            SimplestCalendar(entry: entry, scale: scale)
            SimplestClock(entry: entry, scale: scale)
        }
    }
}

#Preview {
    let entry = SimpleEntry(date: .now, configuration: ConfigurationAppIntent())
    MetricCalendarOnlyComplicationView(entry: entry)
}
