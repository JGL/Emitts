//
//  ParticleSystem.swift
//  FiveTips
//
//  Created by Joel Lewis on 28/09/2023.
//

import SwiftUI

class ParticleSystem{
    //this was a set, but now it's an array because I care about order, so that the drawing looks correct
    //https://developer.apple.com/documentation/swift/set
    //https://developer.apple.com/documentation/swift/array
    var particles = [Particle]()
    var centre = UnitPoint.center
    
    func getParticlesFiltered(by handAction: HandAction) -> [Particle]{
        return particles.filter { $0.handAction == handAction}
    }
    
    func update(date: TimeInterval){
        let deathDate = date - 10 //10 seconds later than now
        
        //https://stackoverflow.com/questions/35101099/how-do-i-safely-remove-items-from-an-array-in-a-for-loop
        let aliveParticles = particles.filter{$0.creationDate > deathDate}
        particles = aliveParticles
        
    }
    
    func add(date: TimeInterval, currentHandAction: HandAction){
        let newParticle = Particle(x: centre.x, y: centre.y, handAction: currentHandAction)
        particles.append(newParticle)
    }
}
