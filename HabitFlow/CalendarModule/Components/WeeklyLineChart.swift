//
//  WeeklyLineChart.swift
//  HabitFlow
//
//  Created by Kirill Atrakhimovich on 12.03.26.
//

import SwiftUI

struct WeeklyLineChart: View {
    let values: [Double]
    let lineColor: Color
    let gridColor: Color

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Grid
                Path { p in
                    let w = geo.size.width
                    let h = geo.size.height
                    p.move(to: CGPoint(x: 0, y: h * 0.33))
                    p.addLine(to: CGPoint(x: w, y: h * 0.33))
                    p.move(to: CGPoint(x: 0, y: h * 0.66))
                    p.addLine(to: CGPoint(x: w, y: h * 0.66))
                }
                .stroke(gridColor, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 4]))

                // Line
                Path { p in
                    let pts = points(in: geo.size)
                    guard let first = pts.first else { return }
                    p.move(to: first)
                    for pt in pts.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                // Dots
                ForEach(Array(points(in: geo.size).enumerated()), id: \.offset) { _, pt in
                    Circle()
                        .fill(lineColor)
                        .frame(width: 7, height: 7)
                        .position(pt)
                }
            }
        }
    }

    private func points(in size: CGSize) -> [CGPoint] {
        let v = values.map { min(1, max(0, $0)) }
        guard v.count >= 2 else { return [] }

        let w = size.width
        let h = size.height

        let stepX = w / CGFloat(v.count - 1)
        let topPadding: CGFloat = 8
        let bottomPadding: CGFloat = 10
        let usableH = max(1, h - topPadding - bottomPadding)

        return v.enumerated().map { idx, val in
            let x = CGFloat(idx) * stepX
            let y = topPadding + (1 - CGFloat(val)) * usableH
            return CGPoint(x: x, y: y)
        }
    }
}
