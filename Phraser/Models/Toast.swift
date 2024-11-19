//
//  Toast.swift
//  Phraser
//
//  Created by Jonas Kaad on 19/11/2024.
//

import Foundation
import SwiftUI

struct ToastNotification: Identifiable {
    let id = UUID()
    let text: String
    let color: Color?
    let icon: String
}
