//
//  ContentView.swift
//  VisualisingGestures
//
//  Created by Joel Lewis on 29/08/2023.
//

import SwiftUI

//thanks to https://www.youtube.com/watch?v=raR-hDgzoFg
//"SwiftUI Special Effects – TimelineView, Canvas, particles, and… AirPods?!"
//Paul Hudson

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

struct HandActionView: View {
    //https://developer.apple.com/documentation/swiftui/managing-user-interface-state
    @Binding var selectedHandAction: HandAction
    @State private var particleSystem = ParticleSystem()
    
    func drawHandDeviationLine(context: GraphicsContext){
        //doing the line drawings for the Wave Hand action in one place
        var handDeviationPath = Path()
        let justHandDeviationParticles = particleSystem.getParticlesFiltered(by: HandAction.handDeviation)
        
        if(!justHandDeviationParticles.isEmpty){
            //this is safe because it's not empty
            let startPosition = CGPoint(x: justHandDeviationParticles.first!.x, y: justHandDeviationParticles.first!.y)
            var nextPosition = startPosition
            
            let numberOfHandDeviationParticles = justHandDeviationParticles.count
            
            var lines = [CGPoint]()
            
            if(numberOfHandDeviationParticles > 2){
                //then we can make at least a line...
                handDeviationPath.move(to: startPosition)
                
                for i in 1..<numberOfHandDeviationParticles{
                    nextPosition = CGPoint(x:justHandDeviationParticles[i].x, y:justHandDeviationParticles[i].y)
                    lines.append(nextPosition)
                }
                
                handDeviationPath.addLines(lines)
                
                context.stroke(
                    handDeviationPath,
                    with: .color(HandAction.handDeviation.colour),
                    lineWidth: 5.0)
            }
        }
    }
    
    func drawSuperNationProNationSpiral(context: GraphicsContext, particle: Particle, size: CGSize, date: TimeInterval){
        //thanks ChatGPT! It made the standard spiral and I distorted it in y
        
        var spiralPath = Path()
        let timeInSecondsSinceBirth = date - particle.creationDate
        //5 seconds to animate offscreen
        let timeToAnimateOffScreen:Double = 5
        let ratioOfMovement = timeInSecondsSinceBirth/timeToAnimateOffScreen
        let heightOfCanvas = size.height
        let animationOffset = ratioOfMovement*heightOfCanvas
        
        let turns: Int = 3
        let distancePerTurn: CGFloat = 0.1
        
        for i in 0..<turns * 360 {
            let angle = Double(i) * .pi / 180
            let x = particle.x + CGFloat(i) * cos(angle) * distancePerTurn
            //distortInYAmount is the stretch of the spiral vertically
            let distortInYAmount = CGFloat(i)/5.0
            let y = -animationOffset + (particle.y - distortInYAmount + (CGFloat(i) * sin(angle) * distancePerTurn))
            
            let point = CGPoint(x: x, y: y)
            
            if i == 0 {
                spiralPath.move(to: point)
            } else {
                spiralPath.addLine(to: point)
            }
        }
        
        context.stroke(
            spiralPath,
            with: .color(HandAction.superNationProNation.colour),
            lineWidth: 12.0)
    }
    
    var body: some View{
        TimelineView(.animation){ timeline in
            Canvas { context, size in
                //drawing code here
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate, currentHandAction: selectedHandAction)
                
                let circleSize = 0.05*size.width
                let halfCircleSize = circleSize/2.0
                let bigSizeMuliplier = 4.0
                let bigCircleSize = circleSize * bigSizeMuliplier
                let bigHalfCircleSize = halfCircleSize * bigSizeMuliplier
                //context.blendMode = .plusLighter
                //context.addFilter(.colorMultiply(.green))
                
                for particle in particleSystem.particles{
                    let xPos = particle.x
                    let yPos = particle.y
                    
                    //fading everything at the moment
                    //context.opacity = 1 - (timelineDate-particle.creationDate)
                    //https://developer.apple.com/documentation/swiftui/canvas
                    //                    context.stroke(
                    //                        Path(ellipseIn: CGRect(origin: CGPoint(x: xPos, y: yPos), size: CGSize(width: 10.0, height: 10.0))),
                    //                            with: .color(.green),
                    //                            lineWidth: 4)
                    
                    switch particle.handAction {
                    case .none:
                        //https://developer.apple.com/documentation/swiftui/graphicscontext
                        context.fill(
                            Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                            with: .color(particle.handAction.colour))
                    case .handDeviation:
                        //path drawing, so all happening in one go below...
                        continue
                    case .superNationProNation:
                        //spirals going up
                        drawSuperNationProNationSpiral(context: context, particle: particle, size: size, date: timelineDate)
                    case .flexionExtension:
                        //balls going up that fall and disappear
                        context.fill(
                            Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                            with: .color(particle.handAction.colour))
                    case .oppositional:
                        //thumb dot gets massive
                        context.fill(
                            Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                            with: .color(particle.handAction.colour))
                    case .elbowDeviation:
                        //fatter paths / bigger dots (TODO: this may not be poassible to track with hand actions alone)
                        context.fill(
                            Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-bigHalfCircleSize, y: yPos-bigHalfCircleSize), size: CGSize(width: bigCircleSize, height: bigCircleSize))),
                            with: .color(particle.handAction.colour))
                    }
                }
                
                //drawing the Hand Deviation aka Wave graphic - a set of continuous lines
                drawHandDeviationLine(context: context)
            }
        }
        .gesture(
            //https://archive.is/jFeHy#selection-1881.0-1881.189
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { drag in
                    //really shouldn't use UISCreen.main.bounds.width / height, but it's ok for now on iPhone
                    //was doing this based on the Paul Hudson tutorial, but since switching to coordinateSpace .local I don't need to any more. Thanks to https://archive.is/jFeHy#selection-1881.0-1881.189 / https://medium.com/devtechie/drawing-app-in-swiftui-3-using-canvas-7f350d8a112
                    //                            particleSystem.centre.x = drag.location.x / UIScreen.main.bounds.width
                    //                            particleSystem.centre.y = drag.location.y / UIScreen.main.bounds.height
                    particleSystem.centre.x = drag.location.x
                    particleSystem.centre.y = drag.location.y
                }
        )
        //make sure it's transparent so the background colour and other things show through from below
        .background(.clear)
    }
}

struct ContentView: View {
    @State private var selectedHandAction: HandAction = .none //start with none
    let appBackgroundColour = UIColor(named: "BackgroundColour")
    
    var body: some View {
        VStack{
            ZStack{
                Rectangle()
                //https://www.hackingwithswift.com/quick-start/swiftui/how-to-load-custom-colors-from-an-asset-catalog
                    .fill(Color("BackgroundColour"))
                HandActionView(selectedHandAction: $selectedHandAction)
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
