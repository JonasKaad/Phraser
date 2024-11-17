//
//  ContextWidgetView.swift
//  Phraser
//
//  Created by Jonas Kaad on 16/11/2024.
//

import SwiftUI

struct ContextWidgetView: View {
    //@StateObject private var locationManager = LocationManager()
    @StateObject private var locationManager = KakaoLocationManager()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Image(systemName: "location")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    Text(locationManager.currentPlace)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    Text(currentTime())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 0, alignment: .leading)
            .padding(8)
            .cornerRadius(10)
            .roundedCornersWithoutBG(color:.purple, lineWidth: 2)
            .padding(.horizontal, 10)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
}

func currentTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter.string(from: Date())
}

#Preview{
    let phrases = ["Good evening!", "How was your day?"];
    ContextualPhraseView(phrases: phrases)
}
