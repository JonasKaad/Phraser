//
//  ContextView.swift
//  Phraser
//
//  Created by Jonas Kaad on 16/11/2024.
//

import SwiftUI

struct ContextView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Image(systemName: "location")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                    Text("DICE Dormitory")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 30))
                        .foregroundColor(.purple)
                    Text(currentTime())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 0, alignment: .leading)
            .padding(8)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
}

func currentTime() -> String {
    let currentHour = Calendar.current.component(.hour, from: Date())
    let currentMinute = Calendar.current.component(.minute, from: Date())
    let currentSecond = Calendar.current.component(.second, from: Date())
    return "\(currentHour):\(currentMinute):\(currentSecond)"
}

#Preview{
    let phrases = ["Good evening!", "How was your day?"];
    ContextualPhraseView(phrases: phrases)
}
