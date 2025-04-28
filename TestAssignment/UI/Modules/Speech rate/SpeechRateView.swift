//
//  SpeechRateView.swift
//  TestAssignment
//
//  Created by Artem Mihelson on 27.04.2025.
//

import SwiftUI

struct SpeechRateView: View {
    @Binding var rate: Float
    
    private let rates: [Float] = [
        Constants.Audio.slowRate,
        Constants.Audio.rate075,
        Constants.Audio.normalRate,
        Constants.Audio.rate15,
        Constants.Audio.fastRate
    ]
    
    var body: some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            // Current rate display
            Text(String(format: String(localized: "Speed: %.1fx"), rate))
                .modifier(RateLabelStyle())

            // Slider
            Slider(
                value: $rate,
                in: Constants.Audio.slowRate...Constants.Audio.fastRate,
                step: 0.1
            ) {
                Text("Speech rate")
            } minimumValueLabel: {
                SliderValueLabel(value: Constants.Audio.slowRate)
            } maximumValueLabel: {
                SliderValueLabel(value: Constants.Audio.fastRate)
            }
            .padding(.horizontal)
            
            // Predefined rate buttons
            HStack {
                ForEach(rates, id: \.self) { predefinedRate in
                    RateButton(rate: predefinedRate, selectedRate: $rate)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Predefined Rate Button

private struct RateButton: View {
    let rate: Float
    @Binding var selectedRate: Float

    var body: some View {
        Button {
            selectedRate = rate
        } label: {
            Text(String(format: "x%.1f", rate))
                .modifier(RateLabelStyle())
        }
    }
}

// MARK: - Common Rate Label Style

private struct RateLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.bold)
            .tint(.primary)
            .padding(Constants.UI.smallPadding)
            .background(.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Constants.UI.smallCornerRadius))
    }
}

private struct SliderValueLabel: View {
    let value: Float
    
    var body: some View {
        Text(String(format: "%.1f", value))
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    SpeechRateView(rate: .constant(Constants.Audio.normalRate))
}
