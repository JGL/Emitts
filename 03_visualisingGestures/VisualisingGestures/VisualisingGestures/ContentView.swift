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

enum HandAction: CaseIterable{
    case none //dots
    case handDeviation //paths
    case superNationProNation //spirals going up
    case flexionExtension //balls going up that fall and disappear
    case oppositional //thumb dot gets massive
    case elbowDeviation //fatter paths / bigger dots (TODO: this may not be poassible to track with hand actions alone)
    
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

struct ContentView: View {
    @State private var particleSystem = ParticleSystem()
    var currentHandAction: HandAction = .none //start with none
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(.orange)
            TimelineView(.animation){ timeline in
                Canvas { context, size in
                    //drawing code here
                    let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                    particleSystem.update(date: timelineDate, currentHandAction: currentHandAction)
                    let circleSize = 0.05*size.width
                    let halfCircleSize = circleSize/2
                    //context.blendMode = .plusLighter
                    //context.addFilter(.colorMultiply(.green))
                    
                    for particle in particleSystem.particles{
                        let xPos = particle.x * size.width
                        let yPos = particle.y * size.height
                        
                        //fading everything at the moment
                        context.opacity = 1 - (timelineDate-particle.creationDate)
                        //https://developer.apple.com/documentation/swiftui/canvas
    //                    context.stroke(
    //                        Path(ellipseIn: CGRect(origin: CGPoint(x: xPos, y: yPos), size: CGSize(width: 10.0, height: 10.0))),
    //                            with: .color(.green),
    //                            lineWidth: 4)
                        
                        
                        switch currentHandAction {
                        case .none:
                            //https://developer.apple.com/documentation/swiftui/graphicscontext
                            context.fill(
                                Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                                with: .color(particle.handAction.colour))
                        case .handDeviation:
                            //paths
                            context.fill(
                                Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                                with: .color(particle.handAction.colour))
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
                                Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                                with: .color(particle.handAction.colour))
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        //really shouldn't use UISCreen.main.bounds.width / height, but it's ok for now on iPhone
                        particleSystem.centre.x = drag.location.x / UIScreen.main.bounds.width
                        particleSystem.centre.y = drag.location.y / UIScreen.main.bounds.height
                    }
            )
            .background(.clear)
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
