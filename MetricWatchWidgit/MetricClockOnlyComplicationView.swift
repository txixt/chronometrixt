//
//  MetricClockOnlyCompilationView.swift
//  MetricWatchWidgitExtension
//
//  Created by Becket Bowes on 1/25/26.
//

import SwiftUI
import WidgetKit

struct MetricClockOnlyComplicationView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall: ClockSystemSmallView(entry: entry)
        case .systemMedium: ClockSystemMediumView(entry: entry)
        case .systemLarge: ClockSystemLargeView(entry: entry)
        case .systemExtraLarge: ClockSystemExtraLargeView(entry: entry)
        case .systemExtraLargePortrait: ClockSystemExtraLargeProtraitView(entry: entry)
        case .accessoryCorner: ClockAccessoryCornerView(entry: entry)
        case .accessoryCircular: ClockAccessoryCircularView(entry: entry)
        case .accessoryRectangular: ClockAccessoryRectangularView(entry: entry)
        case .accessoryInline: ClockAccessoryInlineView(entry: entry)
        default: ClockSystemSmallView(entry: entry)
        }
    }
}

struct ClockSystemSmallView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestClock(entry: entry, scale: 0.25)
        }
    }
}

struct ClockSystemMediumView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestClock(entry: entry, scale: 0.3)
        }
    }
}

struct ClockSystemLargeView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestClock(entry: entry, scale: 0.35)
        }
    }
}

struct ClockSystemExtraLargeView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestClock(entry: entry, scale: 0.4)
        }
    }
}

struct ClockSystemExtraLargeProtraitView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimplestClock(entry: entry, scale: 0.3)
                SimpleMetricText(entry: entry, scale: 0.4)
            }
        }
    }
}

struct ClockAccessoryCornerView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimplestClock(entry: entry, scale: 0.3)
        }
            .widgetLabel {
                Text("\(entry.metricHour):\(entry.metricMinute)")
            }
    }
}

struct ClockAccessoryCircularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        SimplestClock(entry: entry, scale: 0.4)
    }
}

struct ClockAccessoryRectangularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            HStack {
                SimplestClock(entry: entry, scale: 0.45)
                SimpleMetricText(entry: entry, scale: 0.4)
            }
        }
    }
}

struct ClockAccessoryInlineView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricText(entry: entry, scale: 0.15)
            }
        }
    }
}

struct ClockSimpleMetricIcon: View {
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
    let entry = SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    MetricClockOnlyComplicationView(entry: entry)
}
