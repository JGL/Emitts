//
//  ARViewModel.swift
//  FreshStart
//
//  Created by Joel Lewis on 25/09/2023.
//

import Foundation
import RealityKit
import ARKit
import Vision
import SwiftUI

class ARViewModel: UIViewController, ObservableObject, ARSessionDelegate {
    
    @Published private var model : ARModel = ARModel()

    let handActionModel = try! EmittsSupinationAndBackground_1(configuration: MLModelConfiguration())

    var frameCount: Int = 0
    var queue = [MLMultiArray]() // queue of frames to be analyzed by the model
    var queueSamplingCount: Int = 10
    var queueSamplingCounter: Int = 0
    var queueSize: Int = 60 // maximum size of queue of frames
    
    var arView : ARView {
        model.arView
    }
    
    func startSessionDelegate() {
        model.arView.session.delegate = self
    }
    
    func getHands(frame: ARFrame) -> [MLMultiArray] {
        // Function to get hands from AR session
        // Returns an array of tuples containing hand pose (MLMultiArray) and chirality
        
        let pixelBuffer = frame.capturedImage
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        //let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        //thanks to Greg Chiste of  Developer Technical Support for the below bug fix!
        //the image needs an orientation!
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let rotatedImage = image.oriented(.right)
        let handler = VNImageRequestHandler(ciImage: rotatedImage)
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Hand Pose Request Failed: \(error)")
        }
        
        if let handPoses = handPoseRequest.results,
           let handObservation = handPoses.first {
            
            guard let keypointsMultiArray = try? handObservation.keypointsMultiArray() else { fatalError() }
            
            return [keypointsMultiArray]
        }
        
        return []
        
    }

    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        frameCount += 1
        
        if frameCount % 2 == 0 { // 30 frames a second, rather than 60
            
            let hands: [MLMultiArray] = getHands(frame: frame)
            
            for pose in hands {
                
                //loop that forms the MLM MultiArray that will go through the model
                
                queue.append(pose)
                queue = Array(queue.suffix(queueSize))
                queueSamplingCounter += 1
                
                if queue.count == queueSize && queueSamplingCounter % queueSamplingCount == 0 {
                    let poses = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
                    let prediction = try? handActionModel.prediction(poses: poses)
                    
                    guard let label = prediction?.label,
                          let confidence = prediction?.labelProbabilities[label] else {
                        continue
                    }
                    
                    print("\(frameCount): the label is:\(label) with confidence: \(confidence)")
                            
                }
                
                
            }
        }
        
    }
    
    func endSession(){
        model.pauseSession()
    }
    
    func beginSession(){
        model.restartSession()
    }
}
