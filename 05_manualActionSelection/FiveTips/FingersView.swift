//
//  FingersView.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import SwiftUI
import Vision

struct FingersView: View {
    @Binding var namedOverlayPoints:[VNHumanHandPoseObservation.JointName:CGPoint]
    
    var body: some View {
        ZStack(alignment: .top) {
            FingerOverlay(with: namedOverlayPoints[.thumbTip] ?? CGPoint(x: -1, y: -1))
                .foregroundColor(.white)
            FingerOverlay(with: namedOverlayPoints[.indexTip] ?? CGPoint(x: -1, y: -1))
                .foregroundColor(.pink)
            FingerOverlay(with: namedOverlayPoints[.middleTip] ?? CGPoint(x: -1, y: -1))
                .foregroundColor(.green)
            FingerOverlay(with: namedOverlayPoints[.ringTip] ?? CGPoint(x: -1, y: -1))
                .foregroundColor(.blue)
            FingerOverlay(with: namedOverlayPoints[.littleTip] ?? CGPoint(x: -1, y: -1))
                .foregroundColor(.orange)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Couldn't get the preview to work while train hacking so just commented it out
//#Preview {
//    FingersView(namedOverlayPoints: [VNHumanHandPoseObservation.JointName.thumbTip: CGPoint(x: 0.5, y: 0.5)])
//}
