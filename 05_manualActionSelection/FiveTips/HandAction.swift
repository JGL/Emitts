//
//  HandAction.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import Foundation
import SwiftUI

//https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-custom-colors-from-an-asset-catalog

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
            return Color.pink
        case .handDeviation:
            return Color("Navy")
        case .superNationProNation:
            return Color("Violet")
        case .flexionExtension:
            return Color("White")
        case .oppositional:
            return Color("Peach")
        case .elbowDeviation:
            return Color("Orange")
        }
    }
}
