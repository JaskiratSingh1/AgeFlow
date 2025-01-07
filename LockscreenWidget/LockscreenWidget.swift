//
//  LockscreenWidget.swift
//  LockscreenWidget
//
//  Created by Jaskirat Singh on 1/7/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        // Shown in widget gallery before real data is ready
        SimpleEntry(date: Date(), ageString: "27.00000000")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Quick snapshot for the widget preview
        let entry = SimpleEntry(date: Date(), ageString: getAgeString())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Create timeline entries, each valid for a certain time range
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        // For demonstration, let's create 5 entries, 15 seconds apart
        // In practice, iOS may not refresh this frequently on the Lock Screen
        for offset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: offset * 15, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, ageString: getAgeString())
            entries.append(entry)
        }

        // After these entries expire, request a refresh in 1 minute
        let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }
    
    /// Reads the user's birth date from UserDefaults and calculates the current age.
    private func getAgeString() -> String {
        let defaults = UserDefaults(suiteName: "group.com.jaskirat.singh.ageflow.AgeFlow")
        guard let birthDate = defaults?.object(forKey: "userBirthDate") as? Date else {
            // Fallback if no date is saved
            print("Widget Birth date: nil")
            return "0.00000000"
        }
        print("Widget Birth date: \(birthDate)")
        let years = calculateAge(birthDate: birthDate)
        return String(format: "%.5f", years)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let ageString: String
}

struct LockscreenWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        // A single line of text for the Lock Screen (below the clock)
        case .accessoryInline:
            Text(entry.ageString + " years")
            
        // A larger rectangular area (below or above clock, or on the right side)
        case .accessoryRectangular:
            VStack(alignment: .trailing) {
                Text(entry.ageString)
                    .font(.system(.body, design: .monospaced))
                    .bold()
                
                Text("years")
                    .font(.caption)
            }

        default:
            // Fallback for other widget families, if needed
            Text(entry.ageString)
        }
    }
}

struct LockscreenWidget: Widget {
    let kind: String = "LockscreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LockscreenWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LockscreenWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("Displays your age on the Lock Screen.")
        // Choose which Lock Screen families you want to support
        .supportedFamilies([.accessoryInline, .accessoryRectangular])
    }
}

// MARK: - Helper for Calculating Age
func calculateAge(birthDate: Date) -> Double {
    let now = Date()
    let interval = now.timeIntervalSince(birthDate)
    // 1 year ≈ 365.2422 days (accounting for leap years more precisely)
    return interval / (60 * 60 * 24 * 365.2422)
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    LockscreenWidget()
} timeline: {
    SimpleEntry(date: .now, ageString: "27.12345678")
    SimpleEntry(date: .now.addingTimeInterval(15), ageString: "27.12345679")
}
