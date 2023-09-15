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
                var handDeviationPath = Path()
                var firstHandDeviationEncountered = false
                
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
                        //paths
                        //                                context.fill(
                        //                                    Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                        //                                    with: .color(particle.handAction.colour))
                        //context.stroke(Path().addLine(to: CGPoint(x: xPos, y: yPos)), with: .color(particle.handAction.colour), lineWidth: 5)
                        let currentPoint = CGPoint(x: xPos, y: yPos)
                        if(firstHandDeviationEncountered){
                            handDeviationPath.move(to: currentPoint)
                            handDeviationPath.addLine(to: currentPoint)
                            firstHandDeviationEncountered = false
                        }else{
                            handDeviationPath.addLine(to: currentPoint)
                        }
                        //START HERE!
                    case .superNationProNation:
                        //spirals going up
                        context.fill(
                            Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                            with: .color(particle.handAction.colour))
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
                
                //now draw the part we've built up
                context.stroke(
                    handDeviationPath,
                    with: .color(HandAction.handDeviation.colour),
                    lineWidth: 3.0)
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
