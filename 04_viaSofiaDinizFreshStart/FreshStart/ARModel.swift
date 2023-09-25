//
//  ARModel.swift
//  FreshStart
//
//  Created by Joel Lewis on 25/09/2023.
//

import Foundation
import RealityKit
import ARKit
import SwiftUI

struct ARModel {
    private(set) var arView : ARView
    
    init() {
        
        arView = ARView(frame: .zero)
        arView.session.run(ARFaceTrackingConfiguration())
        
    }
    
    func pauseSession(){
        for anchor in arView.scene.anchors {
            arView.scene.removeAnchor(anchor)
        }
        
        arView.session.pause()
        arView.removeFromSuperview()
        
    }
    
    func restartSession(){
        arView.session.run(ARFaceTrackingConfiguration())
    }
    
}


