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
    
    func drawElbowDeviationLine(context: GraphicsContext){
        //doing the line drawings for the Wave Hand action in one place
        var elbowDeviationPath = Path()
        let justElbowDeviationParticles = particleSystem.getParticlesFiltered(by: HandAction.elbowDeviation)
        
        if(!justElbowDeviationParticles.isEmpty){
            //this is safe because it's not empty
            let startPosition = CGPoint(x: justElbowDeviationParticles.first!.x, y: justElbowDeviationParticles.first!.y)
            var nextPosition = startPosition
            
            let numberOfElbowDeviationParticles = justElbowDeviationParticles.count
            
            var lines = [CGPoint]()
            
            if(numberOfElbowDeviationParticles > 2){
                //then we can make at least a line...
                elbowDeviationPath.move(to: startPosition)
                
                for i in 1..<numberOfElbowDeviationParticles{
                    nextPosition = CGPoint(x:justElbowDeviationParticles[i].x, y:justElbowDeviationParticles[i].y)
                    lines.append(nextPosition)
                }
                
                elbowDeviationPath.addLines(lines)
                
                context.stroke(
                    elbowDeviationPath,
                    with: .color(HandAction.elbowDeviation.colour),
                    lineWidth: 10.0)
            }
        }
    }
    
    func drawFlexionExtensionBall(context: GraphicsContext, particle: Particle, size: CGSize, date: TimeInterval){
        
        let timeInSecondsSinceBirth = date - particle.creationDate
        //5 seconds to animate offscreen
        let timeToAnimateOffScreen:Double = 4.2
        let ballSize:Double = 21
        let ratioOfMovement = timeInSecondsSinceBirth/timeToAnimateOffScreen
        let heightOfCanvas = size.height
        let animationOffset = ratioOfMovement*heightOfCanvas
        let newY = particle.y - animationOffset
        
        //https://developer.apple.com/documentation/swiftui/graphicscontext
        let ballPath = Path(ellipseIn: CGRect(origin: CGPoint(x: particle.x, y: newY), size: CGSize(width: ballSize, height: ballSize)))
        
        context.fill(
            ballPath,
            with: .color(particle.handAction.colour))
    }
    
    func drawSuperNationProNationSpiral(context: GraphicsContext, particle: Particle, size: CGSize, date: TimeInterval){
        //thanks ChatGPT! It made the standard spiral and I distorted it in y
        
        var spiralPath = Path()
        let timeInSecondsSinceBirth = date - particle.creationDate
        //5 seconds to animate offscreen
        let timeToAnimateOffScreen:Double = 4.2*2
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
            with: .color(particle.handAction.colour),
            lineWidth: 6.0)
    }
    
    var body: some View{
        TimelineView(.animation){ timeline in
            Canvas { context, size in
                //drawing code here
                let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: timelineDate)
                
                let noneCircleSize = 0.05*size.width
                let halfNoneCircleSize = noneCircleSize/2.0
                let oppositionalSizeMuliplier = 2.0
                let oppositionalCircleSize = noneCircleSize*oppositionalSizeMuliplier
                let halfOppositionalCircleSize = oppositionalCircleSize/2.0
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
                    
                    switch particle.handAction {
                    case .none:
                        //https://developer.apple.com/documentation/swiftui/graphicscontext
                        context.fill(
                            Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfNoneCircleSize, y: yPos-halfNoneCircleSize), size: CGSize(width: noneCircleSize, height: noneCircleSize))),
                            with: .color(particle.handAction.colour))
                    case .handDeviation:
                        //path drawing, so all happening in one go below...
                        continue
                    case .superNationProNation:
                        //spirals going up
                        drawSuperNationProNationSpiral(context: context, particle: particle, size: size, date: timelineDate)
                    case .flexionExtension:
                        //balls going up (TODO: that fall and disappear)
                        drawFlexionExtensionBall(context: context, particle: particle, size: size, date: timelineDate)
                    case .oppositional:
                        if(particle.tipType == .thumbTip){
                            //thumb dot gets massive
                            context.fill(Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfOppositionalCircleSize, y: yPos-halfOppositionalCircleSize), size: CGSize(width: oppositionalCircleSize, height: oppositionalCircleSize))),
                            with: .color(particle.handAction.colour))
                        }else{
                            //other dots "normal" size
                            context.fill(
                                Path(ellipseIn: CGRect(origin: CGPoint(x: xPos-halfNoneCircleSize, y: yPos-halfNoneCircleSize), size: CGSize(width: noneCircleSize, height: noneCircleSize))),
                                with: .color(particle.handAction.colour))
                        }
                    
                    case .elbowDeviation:
                        //fatter paths / bigger dots (TODO: this may not be poassible to track with hand actions alone)
                        //bigger path drawing, so all happening in one go below...
                        continue
                    }
                }
                
                //drawing the Hand Deviation aka Wave graphic - a set of continuous lines
                drawHandDeviationLine(context: context)
                //drawing the Elbow Deviation aka Elbow Wave graphic - a set of bigger continuous lines
                drawElbowDeviationLine(context: context)
            }
        }
        //make sure it's transparent so the background colour and other things show through from below
        .background(.clear)
    }
}

