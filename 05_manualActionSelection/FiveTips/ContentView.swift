//
//  ContentView.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import SwiftUI
import RealityKit
import ARKit //importing so I can configure to use the front facing camera
import Vision

struct ContentView : View {
    @State private var selectedHandAction: HandAction = .none //start with none
    let appBackgroundColour = UIColor(named: "BackgroundColour")
    
    @State private var namedOverlayPoints: [VNHumanHandPoseObservation.JointName:CGPoint] = [.thumbTip: CGPoint(), .indexTip: CGPoint(), .middleTip: CGPoint(), .ringTip: CGPoint(), .littleTip: CGPoint()]
    
    @State private var thumbParticleSystem:ParticleSystem = ParticleSystem()
    
    var body: some View {
        VStack{
            ZStack(alignment: .top) {
                Rectangle()
                //https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-custom-colors-from-an-asset-catalog
                    .fill(Color("BackgroundColour"))
                ARViewContainer(namedOverlayPoints: $namedOverlayPoints)
                FingersView(namedOverlayPoints: $namedOverlayPoints)
                GeometryReader { geometry in
                    HandActionView(selectedHandAction: $selectedHandAction, particleSystem: $thumbParticleSystem)
                        .onChange(of: namedOverlayPoints){
                            let now = Date().timeIntervalSinceReferenceDate
                            if(namedOverlayPoints[.thumbTip] != nil){
                                thumbParticleSystem.centre.x = namedOverlayPoints[.thumbTip]!.x * geometry.size.width
                                thumbParticleSystem.centre.y = namedOverlayPoints[.thumbTip]!.y * geometry.size.height
                                
                                thumbParticleSystem.add(date:now, currentHandAction: selectedHandAction)
                            }
                            thumbParticleSystem.update(date: now)
                        }
                }
            }
            .edgesIgnoringSafeArea(.all)
            //https://developer.apple.com/documentation/swiftui/picker
            HStack{
                Text("Current Hand Action:")
                Picker("What is the point of this label", selection: $selectedHandAction) {
                    Text("None").tag(HandAction.none)
                    Text("Hand Deviation").tag(HandAction.handDeviation)
                    Text("Supernation Pronation").tag(HandAction.superNationProNation)
                    Text("Flexion Extension").tag(HandAction.flexionExtension)
                    Text("Oppostitional").tag(HandAction.oppositional)
                    Text("Elbow Deviation").tag(HandAction.elbowDeviation)
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    //https://www.swiftbysundell.com/tips/importing-interactive-uikit-views-into-swiftui
    @Binding var namedOverlayPoints:[VNHumanHandPoseObservation.JointName:CGPoint]
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        //duplicated from: https://github.com/ralfebert/ARDice
        let session = arView.session
        let config = ARFaceTrackingConfiguration()
        session.run(config)
        
        context.coordinator.view = arView
        session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    //Creates the custom instance that you use to communicate changes from your view controller to other parts of your SwiftUI interface.
    //https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable/makecoordinator()-32trb
    //https://www.swiftbysundell.com/tips/importing-interactive-uikit-views-into-swiftui
    func makeCoordinator() -> Coordinator {
        Coordinator(namedOverlayPoints: $namedOverlayPoints)
    }
}

class Coordinator: NSObject, ARSessionDelegate {
    @Binding private var namedOverlayPoints:[VNHumanHandPoseObservation.JointName:CGPoint]
    
    weak var view: ARView?
    var queue = [MLMultiArray]()
    var queueSamplingCounter = 0
    let queueSize = 60 //that's the prediction window size from the .mlmodel file
    let queueSamplingCount = 1 //10 //try to work out the action every 10 frames, as soon as the queue is full, guessed this value
    var frameCounter = 0
    
    let handActionModel = try! EmittsSupinationAndBackground_1(configuration: MLModelConfiguration())
    
    //https://www.swiftbysundell.com/tips/importing-interactive-uikit-views-into-swiftui
    init(namedOverlayPoints: Binding<[VNHumanHandPoseObservation.JointName:CGPoint]>){
        _namedOverlayPoints = namedOverlayPoints
    }
    
    func convertVNRecognizedPointToCGPoint(_ pointToConvert:VNRecognizedPoint) -> CGPoint{
        //swap them!
        //https://stackoverflow.com/questions/64759383/bounding-box-from-vndetectrectanglerequest-is-not-correct-size-when-used-as-chil/66054211#66054211
        //https://stackoverflow.com/questions/68280813/convert-points-from-vision-coordinates-to-uikit-coordinates-in-vndetecthumanhand
        return CGPoint(x: pointToConvert.location.y, y: pointToConvert.location.x)
        //can't use the below as we are using ARKit for capture, not AVCapture
        //TODO: go back to using AVController for capture?
        //return cameraPreview.previewLayer.layerPointConverted(fromCaptureDevicePoint: cgPoint)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let viewWidth = Int(view!.bounds.width)
        let viewHeight = Int(view!.bounds.height)
        
        //code below via: "Classify hand poses and actions with Create ML" WWDC 2021 session
        //https://developer.apple.com/videos/play/wwdc2021/10039/
        let pixelBuffer = frame.capturedImage
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            
            guard let results = handPoseRequest.results?.prefix(1),
                  !results.isEmpty
            else { return }
            
            try results.forEach { observation in
                
                let handLandmarks = try observation.recognizedPoints(.all)
                    .filter { point in
                        point.value.confidence > 0.6
                    }
                
                //[VNHumanHandPoseObservation.JointName : VNRecognizedPoint]
                //handLandmarks.
                
                //each of these constants is either nil or a value
                let thumbTipObservation = handLandmarks[.thumbTip]
                let indexTipObservation = handLandmarks[.indexTip]
                let middleTipObservation = handLandmarks[.middleTip]
                let ringTipObservation = handLandmarks[.ringTip]
                let littleTipObservation = handLandmarks[.littleTip]

                //TODO: clean this up, must be a way of mapping this with a closure
                if (thumbTipObservation != nil){
                    namedOverlayPoints[.thumbTip] = convertVNRecognizedPointToCGPoint(thumbTipObservation!)
                }else{
                    namedOverlayPoints[.thumbTip] = nil
                }
                
                if (indexTipObservation != nil){
                    namedOverlayPoints[.indexTip] = convertVNRecognizedPointToCGPoint(indexTipObservation!)
                }else{
                    namedOverlayPoints[.indexTip] = nil
                }
                
                if (middleTipObservation != nil){
                    namedOverlayPoints[.middleTip] = convertVNRecognizedPointToCGPoint(middleTipObservation!)
                }else{
                    namedOverlayPoints[.middleTip] = nil
                }
                
                if (ringTipObservation != nil){
                    namedOverlayPoints[.ringTip] = convertVNRecognizedPointToCGPoint(ringTipObservation!)
                }else{
                    namedOverlayPoints[.ringTip] = nil
                }
                
                if (littleTipObservation != nil){
                    namedOverlayPoints[.littleTip] = convertVNRecognizedPointToCGPoint(littleTipObservation!)
                }else{
                    namedOverlayPoints[.littleTip] = nil
                }
                
                //print("convertedPoints: \(convertedPoints)")
                
                //pass the points at this point!
                //overlayPoints = convertedPoints
                
                frameCounter += 1
                //only try every two frames so we are running at 30fps not 60fps which matches our model and training data
                if frameCounter % 2 == 0 {
                    do {
                        let oneFrameMultiArray = try observation.keypointsMultiArray()
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
                        //print("\(frameCounter): the label is:\(label) with confidence: \(confidence)")
                    }
                    
                }
            }
        } catch {
            assertionFailure("handPoseRequest failed: \(error.localizedDescription)")
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        //guard let view = self.view else { return }
    }
}

#Preview {
    ContentView()
}
