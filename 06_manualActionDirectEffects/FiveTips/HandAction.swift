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
    case handDeviation //used to be paths, now all dots
    case superNationProNation //used to be spirals going up, now all dots
    case flexionExtension //used to be balls going up that fall and disappear, now all dots
    case oppositional //used to be thumb dot gets massive, now all dots
    case elbowDeviation //used to be fatter paths / bigger dots (TODO: this may not be possible to track with hand actions alone), now all dots
    
    var id: Self { self } //necessary to be Identifiable
    
    var colour: Color {
        switch self {
        case .none:
            return Color.pink
        case .handDeviation:
            return Color("EmittsNavy")
        case .superNationProNation:
            return Color("EmittsViolet")
        case .flexionExtension:
            return Color("EmittsWhite")
        case .oppositional:
            return Color("EmittsPeach")
        case .elbowDeviation:
            return Color("EmittsOrange")
        }
    }
}
