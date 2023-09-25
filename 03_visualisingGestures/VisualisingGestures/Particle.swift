//
//  Particle.swift
//  VisualisingGestures
//
//  Created by Joel Lewis on 29/08/2023.
//

import Foundation

struct Particle: Hashable {
    let x: Double
    let y: Double
    let creationDate = Date.now.timeIntervalSinceReferenceDate
    let handAction: HandAction
}
