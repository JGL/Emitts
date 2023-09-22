//
//  ContentView.swift
//  TestingRealityKitWithSwiftUI
//
//  Created by Joel Lewis on 14/08/2023.
//

import SwiftUI
import RealityKit
import ARKit //importing so I can configure to use the front facing camera
import Vision

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // not using the Reality Kit file this time
        //        // Load the "Box" scene from the "Experience" Reality File
        //        let boxAnchor = try! Experience.loadBox()
        //
        //        // Add the box anchor to the scene
        //        arView.scene.anchors.append(boxAnchor)
        
        //duplicated from: https://github.com/ralfebert/ARDice
        let session = arView.session
        let config = ARFaceTrackingConfiguration()
        session.run(config)
        
        context.coordinator.view = arView
        session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    //Creates the custom instance that you use to communicate changes from your view controller to other parts of your SwiftUI interface.
    //https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable/makecoordinator()-32trb
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

class Coordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var queue = [MLMultiArray]()
    var queueSamplingCounter = 0
    let queueSize = 60 //that's the prediction window size from the .mlmodel file
    let queueSamplingCount = 1 //10 //try to work out the action every 10 frames, as soon as the queue is full, guessed this value
    var frameCounter = 0
    
    //https://www.hackingwithswift.com/forums/swiftui/betterrest-init-deprecated/2593
    let handActionModel: SupinationAndBackground = {
        do {
            let config = MLModelConfiguration()
            return try SupinationAndBackground(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SupinationAndBackground model")
        }
    }()
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //code below via: "Classify hand poses and actions with Create ML" WWDC 2021 session
        //https://developer.apple.com/videos/play/wwdc2021/10039/
        let pixelBuffer = frame.capturedImage
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("handPoseRequest failed: \(error)")
        }
        
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
            // No effects to draw, so clear out current graphics
            return
        }
        let handObservation = handPoses.first
        //print("Got a hand!")
        
        frameCounter += 1
        if frameCounter % 2 == 0 {
            let pose = handObservation
            do {
                let oneFrameMultiArray = try pose!.keypointsMultiArray()
                queue.append(oneFrameMultiArray)
                //print("Appended to queue!")
            } catch {
                print("Couldn't add the keypoints to the queue")
                print(error.localizedDescription)
            }
            
            queue = Array(queue.suffix(queueSize))
            //geppy thinks it's the reversed queue that is wrong, the order of frames I'm feeding it
            //let reversedQueue = queue.reversed()
            
            queueSamplingCounter += 1
            if queue.count == queueSize && queueSamplingCounter % queueSamplingCount == 0 {
                let poses = MLMultiArray(concatenating: queue, axis: 0, dataType: .float32)
                let prediction = try? handActionModel.prediction(poses: poses)
                guard let label = prediction?.label,
                      let confidence = prediction?.labelProbabilities[label] else {
                    print("Couldn't get a label or a confidence, returning...")
                    return
                }
                print("\(frameCounter): the label is:\(label) with confidence: \(confidence)")
            }
            
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        //guard let view = self.view else { return }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
