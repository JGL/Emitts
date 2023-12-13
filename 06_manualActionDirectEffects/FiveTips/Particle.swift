//
//  Particle.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import Foundation
import Vision

struct Particle: Hashable {
    let x: Double
    let y: Double
    let creationDate = Date.now.timeIntervalSinceReferenceDate
    let handAction: HandAction
    let tipType: VNHumanHandPoseObservation.JointName
}
