//
//  ComplicationView.swift
//  MetricWatchWidgitExtension
//
//  Created by Becket on 1/23/26.
//

import SwiftUI
import WidgetKit

struct ComplicationView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall: SystemSmallView(entry: entry)
        case .systemMedium: SystemMediumView(entry: entry)
        case .systemLarge: SystemLargeView(entry: entry)
        case .systemExtraLarge: SystemExtraLargeView(entry: entry)
        case .systemExtraLargePortrait: SystemExtraLargePortraitView(entry: entry)
        case .accessoryCorner: AccessoryCornerView(entry: entry)
        case .accessoryCircular: AccessoryCircularView(entry: entry)
        case .accessoryRectangular: AccessoryRectangularView(entry: entry)
        case .accessoryInline: AccessoryInlineView(entry: entry)
        default: SystemSmallView(entry: entry)
        }
    }
}


struct SystemSmallView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            SimpleMetricIcon(entry: entry, scale: 0.15)
        }
    }
}

struct SystemMediumView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricIcon(entry: entry, scale: 0.2)
                SimpleMetricText(entry: entry, scale: 0.2)
            }
        }
    }
}

struct SystemLargeView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricIcon(entry: entry, scale: 0.3)
                SimpleMetricText(entry: entry, scale: 0.2)
            }
        }
    }
}

struct SystemExtraLargeView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricIcon(entry: entry, scale: 0.3)
                SimpleMetricText(entry: entry, scale: 0.2)
            }
        }
    }
}

struct SystemExtraLargePortraitView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricIcon(entry: entry, scale: 0.3)
                SimpleMetricText(entry: entry, scale: 0.2)
            }
        }
    }
}

struct AccessoryCornerView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricIcon(entry: entry, scale: 0.18)
                    .widgetLabel {
                        Text("\(entry.metricYear)•\(entry.metricDay)•\(entry.metricHour):\(entry.metricMinute)")
                    }
            }
        }
    }
}

struct AccessoryCircularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        SimplestClock(entry: entry, scale: 0.4)
    }
}

struct AccessoryRectangularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            HStack {
                SimpleMetricIcon(entry: entry, scale: 0.4)
                SimpleMetricText(entry: entry, scale: 0.4)
            }
        }
    }
}

struct AccessoryInlineView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            VStack {
                SimpleMetricText(entry: entry, scale: 0.15)
            }
        }
    }
}

struct SimpleMetricIcon: View {
    var entry: SimpleEntry
    var scale: CGFloat = 0.15
    
    var body: some View {
        HStack {
            SimplestCalendar(entry: entry, scale: scale)
            SimplestClock(entry: entry, scale: scale)
        }
    }
}

struct SimplestCalendar: View {
    var entry: SimpleEntry
    var scale: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 2 * scale)
                .fill(.secondary)
            
            RoundedRectangle(cornerRadius: 2 * scale)
                .fill(Color.primary)
                .frame(height: 100 * scale * entry.percentOfYear)
                .mask(
                    RoundedRectangle(cornerRadius: 2 * scale)
                )
        }
        .frame(width: 20 * scale, height: 100 * scale)
        .padding(.trailing, scale > 0.3 ? 0 : -3)
    }
}

struct SimplestClock: View {
    var entry: SimpleEntry
    var scale: CGFloat
    
    var body: some View {
        ZStack {
            Circle().frame(width: scale * 100, height: scale * 100)
                .foregroundColor(.secondary)
            
            if scale > 0.35 {
                ForEach(0..<10) { hour in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8 * scale, height: 8 * scale)
                        .offset(y: scale * 40)
                        .rotationEffect(.degrees(Double(hour) * 36)) // 360/10
                }
            }
            
            RoundedRectangle(cornerRadius: 4 * scale)
                .fill(Color.primary)
                .frame(width: 8 * scale, height: 30 * scale)
                .offset(x: 0, y: -15 * scale)
                .rotationEffect(Angle(degrees: entry.hourRotation))
            
            RoundedRectangle(cornerRadius: 2.5 * scale)
                .fill(Color.primary)
                .frame(width: 5 * scale, height: 50 * scale)
                .offset(x: 0, y: -25 * scale)
                .rotationEffect(Angle(degrees: entry.minuteRotation))
            
            Circle().frame(width: scale * 10, height: scale * 10)
                .foregroundColor(Color.black)
            
        }
    }
}

struct SimpleMetricText: View {
    var entry: SimpleEntry
    var scale: CGFloat = 1.5
    let cal: Calendar = .current

    var body: some View {
        if scale > 0.5 {
          
            VStack(spacing: 0) {
                Text(entry.metricYear + "•" + entry.metricDay)
            }
            
        } else if scale > 0.3 {
            
            VStack(spacing: 0) {
                Text(entry.metricYear + "•" + entry.metricDay)
                Text(entry.metricHour + ":" + entry.metricMinute)
            }
            
        } else {
            
            HStack(spacing: 0) {
                if scale > 0.2 {
                    Text(entry.metricDay + "•")
                }
                Text(entry.metricHour + ":" + entry.metricMinute)
            }
            
        }
    }
}
//#Preview {
//    ComplicationView(entry: .constant(Provider.placeholde))
//}
