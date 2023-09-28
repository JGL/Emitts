//
//  HandAction.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import Foundation
import SwiftUI

//https://www.programiz.com/swift-programming/enum caseiterable is useful!
enum HandAction: String, CaseIterable, Identifiable{
    case none //dots
    case handDeviation //paths
    case superNationProNation //spirals going up
    case flexionExtension //balls going up that fall and disappear
    case oppositional //thumb dot gets massive
    case elbowDeviation //fatter paths / bigger dots (TODO: this may not be possible to track with hand actions alone)
    
    var id: Self { self } //necessary to be Identifiable
    
    var colour: Color {
        switch self {
        case .none:
            return Color.green
        case .handDeviation:
            return Color.red
        case .superNationProNation:
            return Color.blue
        case .flexionExtension:
            return Color.purple
        case .oppositional:
            return Color.pink
        case .elbowDeviation:
            return Color.white
        }
    }
}
