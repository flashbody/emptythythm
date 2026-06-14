import WidgetKit
import SwiftUI

// MARK: - 断食进度小组件
struct FastingWidget: Widget {
    let kind = "FastingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingWidgetProvider()) { entry in
            FastingWidgetView(entry: entry)
        }
        .configurationDisplayName("EmptyRhythm")
        .description("Track your fasting progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FastingWidgetEntry: TimelineEntry {
    let date: Date
    let progress: Double
    let elapsedHours: Double
    let targetHours: Int
    let state: String
}

struct FastingWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FastingWidgetEntry {
        FastingWidgetEntry(date: Date(), progress: 0.6, elapsedHours: 9.6, targetHours: 16, state: "Fasting")
    }

    func getSnapshot(in context: Context, completion: @escaping (FastingWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FastingWidgetEntry>) -> Void) {
        let entry = FastingWidgetEntry(date: Date(), progress: 0.5, elapsedHours: 8, targetHours: 16, state: "Fasting")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct FastingWidgetView: View {
    let entry: FastingWidgetEntry

    var body: some View {
        ZStack {
            Color(UIColor(hex: "#F8F9FA"))
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color(UIColor(hex: "#E5E5EA")), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: entry.progress)
                        .stroke(Color(UIColor(hex: "#4CC999")), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(String(format: "%.0f%%", entry.progress * 100))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(UIColor(hex: "#4CC999")))
                }
                .frame(width: 80, height: 80)

                Text(entry.state)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

@main
struct EmptyRhythmWidgetBundle: WidgetBundle {
    var body: some Widget {
        FastingWidget()
    }
}
