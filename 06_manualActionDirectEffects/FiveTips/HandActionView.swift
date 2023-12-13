//
//  HandActionView.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import SwiftUI

//thanks to https://www.youtube.com/watch?v=raR-hDgzoFg
//"SwiftUI Special Effects – TimelineView, Canvas, particles, and… AirPods?!"
//Paul Hudson

struct HandActionView: View {
    //https://developer.apple.com/documentation/swiftui/managing-user-interface-state
    @Binding var selectedHandAction: HandAction
    @Binding var particleSystem: ParticleSystem
    
    var body: some View{
        TimelineView(.animation){ timeline in
            Canvas { context, size in
                //drawing code here
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate)
                
                let circleSize = 0.05*size.width
                let halfCircleSize = circleSize/2.0
                //https://developer.apple.com/documentation/swiftui/graphicscontext/opacity
                //to fade everything:
                //context.opacity = 0.84
                //https://developer.apple.com/documentation/swiftui/graphicscontext/blendmode-swift.struct
                //context.blendMode = .darken
                //context.addFilter(.colorMultiply(.green))
                //blurry!
                //context.addFilter(.blur(radius: 2.0))
                
                for particle in particleSystem.particles{
                    let xPos = particle.x
                    let yPos = particle.y
                    
                    //fading everything at the moment
                    context.opacity = 1.0 - (timelineDate-particle.creationDate)
                    //https://developer.apple.com/documentation/swiftui/canvas
                    //                    context.stroke(
                    //                        Path(ellipseIn: CGRect(origin: CGPoint(x: xPos, y: yPos), size: CGSize(width: 10.0, height: 10.0))),
                    //                            with: .color(.green),
                    //                            lineWidth: 4)
                    
                    //https://developer.apple.com/documentation/swiftui/graphicscontext
                    context.fill(
                        Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfCircleSize, y: yPos-halfCircleSize), size: CGSize(width: circleSize, height: circleSize))),
                        with: .color(particle.handAction.colour))
                }
            }
        }
        //make sure it's transparent so the background colour and other things show through from below
        .background(.clear)
    }
}

